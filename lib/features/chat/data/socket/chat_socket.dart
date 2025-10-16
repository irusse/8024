import 'dart:async';
import 'package:injectable/injectable.dart';
import 'package:neighbours/core/logging/logger.dart';
import 'package:socket_io_client/socket_io_client.dart' as io;
import 'package:neighbours/core/config/app_config.dart';
import 'package:neighbours/core/services/auth_service.dart';

@Singleton()
class ChatSocket {
  final AuthService _authService;

  ChatSocket(this._authService);

  io.Socket? _socket;
  bool _isConnected = false;
  StreamSubscription<String?>? _tokenSub;

  final Map<String, Set<int>> _roomsToJoin = {
    'joinEvent': <int>{},
    'community:join': <int>{},
    'private:join': <int>{},
  };

  final Map<String, List<Function(dynamic)>> _listeners = {};

  bool get isConnected => _isConnected;
  io.Socket? get socket => _socket;

  static bool _isInitialized = false; // защита от повторного init

  Future<void> initializeSocket() async {
    if (_isInitialized) {
      AppLogger.debug('[ChatSocket] already initialized — skipping');
      return;
    }
    _isInitialized = true;

    AppLogger.info('[ChatSocket] initialize (hash: ${identityHashCode(this)})');

    // слушаем токен — только один раз
    _tokenSub = _authService.accessTokenStream.listen((token) async {
      if (token == null || token.isEmpty) {
        _teardownSocket();
        return;
      }
      await _reconnectWithToken(token);
    });

    final token = await _authService.getAccessToken();
    if (token != null && token.isNotEmpty) {
      await _reconnectWithToken(token);
    }
  }

  Future<void> _reconnectWithToken(String token) async {
    AppLogger.debug('[ChatSocket] reconnect with token');

    _teardownSocket();

    final opts = io.OptionBuilder()
        .setTransports(['websocket'])
        .disableAutoConnect()
        .setPath('/socket.io/')
        .enableReconnection()
        .setReconnectionDelay(1000)
        .setReconnectionDelayMax(5000)
        .setTimeout(20000)
        .setQuery({'token': token})
        .enableForceNew()
        .build();

    _socket = io.io(AppConfig.socketUrl, opts);
    _setupSocketListeners();
    _socket!.connect();
  }

  void _setupSocketListeners() {
    if (_socket == null) return;

    AppLogger.info('[ChatSocket] setting up listeners (hash: ${identityHashCode(this)})');

    _socket!.onConnect((_) {
      _isConnected = true;
      AppLogger.info('[ChatSocket] connected ✅');

      _restoreListeners();

      for (final entry in _roomsToJoin.entries) {
        for (final id in entry.value) {
          emit(entry.key, id);
        }
      }
    });

    _socket!.onDisconnect((_) {
      _isConnected = false;
      AppLogger.error('[ChatSocket] disconnected');
    });

    _socket!.onConnectError((err) {
      _isConnected = false;
      AppLogger.error('[ChatSocket] connect error: $err');
    });
  }

  bool get isSocketReallyConnected =>
      _isConnected && (_socket?.connected ?? false);

  void emit(String event, dynamic data) {
    if (!isSocketReallyConnected) {
      AppLogger.error('[ChatSocket] emit failed (no connection): $event');
      return;
    }
    _socket!.emitWithAck(event, data, ack: (res) {
      AppLogger.debug('[ChatSocket] $event -> $res');
    });
  }

  void on(String event, Function(dynamic) handler) {
    _listeners.putIfAbsent(event, () => []).add(handler);
    _socket?.on(event, handler);
  }

  void off(String event, [Function(dynamic)? handler]) {
    if (handler != null) {
      _listeners[event]?.remove(handler);
      if (_listeners[event]?.isEmpty ?? false) {
        _listeners.remove(event);
      }
    } else {
      _listeners.remove(event);
    }
    _socket?.off(event, handler);
  }

  void _restoreListeners() {
    for (final entry in _listeners.entries) {
      final event = entry.key;
      _socket?.off(event);
      for (final handler in entry.value) {
        _socket?.on(event, handler);
      }
    }
    AppLogger.debug('[ChatSocket] restored ${_listeners.length} events');
  }

  void joinRoom(String type, int id) {
    _roomsToJoin.putIfAbsent(type, () => <int>{}).add(id);
    if (isSocketReallyConnected) emit(type, id);
  }

  void leaveRoom(String type, int id) {
    _roomsToJoin[type]?.remove(id);
    if (isSocketReallyConnected) emit(type, id);
  }

  Future<void> forceReconnect() async {
    AppLogger.info('[ChatSocket] force reconnect...');
    final token = await _authService.getAccessToken();
    if (token != null && token.isNotEmpty) {
      await _reconnectWithToken(token);
    }
  }

  void disconnect() {
    AppLogger.info('[ChatSocket] disconnect called');
    _roomsToJoin.clear();
    _listeners.clear();
    _teardownSocket();

    _tokenSub?.cancel();
    _tokenSub = null;
    _isInitialized = false; // теперь можно безопасно вызвать initialize заново
  }

  void _teardownSocket() {
    if (_socket != null) {
      AppLogger.debug('[ChatSocket] tearing down socket');
      _socket!.dispose();
      _socket = null;
    }
    _isConnected = false;
  }
}
