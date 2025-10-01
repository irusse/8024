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
  };

  io.Socket? get socket => _socket;

  bool get isConnected => _isConnected;

  Future<void> initializeSocket() async {
    _tokenSub ??= _authService.accessTokenStream.listen((token) async {
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

    _socket = io.io("${AppConfig.socketUrl}", opts);
    _setupSocketListeners();
    _socket!.connect();
  }

  void _setupSocketListeners() {
    _socket?.onConnect((_) {
      _isConnected = true;

      // при реконнекте автоматически восстанавливаем комнаты
      for (final entry in _roomsToJoin.entries) {
        final type = entry.key;
        for (final id in entry.value) {
          AppLogger.debug("Trying to $type $id");
          emit(type, id);
        }
      }
    });

    _socket?.onDisconnect((error) {
      _isConnected = false;
      AppLogger.error(error.toString());
    });
    _socket?.onConnectError((error) {
      _isConnected = false;
      AppLogger.error(error.toString());
    });
  }

  void emit(String event, dynamic data) {
    if (!_isConnected || _socket == null) {
      AppLogger.error('Emit failed: socket not connected [$event]');
      return;
    }
    _socket!.emitWithAck(event, data, ack: (res) {
      AppLogger.info(event);
      AppLogger.info(res.toString());
      AppLogger.info(data.toString());
    });
  }

  void on(String event, Function(dynamic) handler) {
    _socket?.on(event, handler);
  }

  void joinRoom(String type, int id) {
    _roomsToJoin.putIfAbsent(type, () => <int>{}).add(id);
    AppLogger.info(_roomsToJoin.toString());
    if (_isConnected) {
      emit(type, id);
    }
  }

  void leaveRoom(String type, int id) {
    _roomsToJoin[type]?.remove(id);
    if (_isConnected) {
      emit(type, id);
    }
  }

  void disconnect() {
    _roomsToJoin.clear();
    _teardownSocket();
    _tokenSub?.cancel();
    _tokenSub = null;
  }

  void _teardownSocket() {
    _socket?.dispose();
    _socket = null;
    _isConnected = false;
  }
}
