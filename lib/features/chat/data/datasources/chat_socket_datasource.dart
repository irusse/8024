import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:injectable/injectable.dart';
import 'package:neighbours/features/chat/data/models/message/message_model.dart';
import 'package:socket_io_client/socket_io_client.dart' as io;
import 'package:neighbours/core/config/app_config.dart';
import 'package:neighbours/core/services/auth_service.dart';

@singleton
class ChatSocketDataSource {
  final AuthService _authService;

  ChatSocketDataSource(this._authService);

  io.Socket? _socket;
  bool _isConnected = false;
  StreamSubscription<String?>? _tokenSub;

  final Set<int> _roomsToJoin = <int>{};

  io.Socket? get socket => _socket;

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

    _socket = io.io(AppConfig.socketUrl, opts);
    _setupSocketListeners();
    _socket!.connect();
  }

  void _setupSocketListeners() {
    _socket?.onConnect((_) {
      _isConnected = true;
      for (final id in _roomsToJoin) {
        _emitJoin(id);
      }
    });

    _socket?.onDisconnect((_) {
      _isConnected = false;
    });

    _socket?.onConnectError((error) {
      _isConnected = false;
    });
  }

  void _emitJoin(int eventId) {
    _socket!.emit('joinEvent', eventId);
  }

  void joinEvent(int eventId) {
    if (_socket == null) {
      _roomsToJoin.add(eventId);
      debugPrint('Socket not initialized yet. Queued join for $eventId');
      return;
    }
    if (!_isConnected) {
      _roomsToJoin.add(eventId);
      debugPrint('Socket not connected. Queued join for $eventId');
      return;
    }
    // Уже подключены — вступаем сразу
    _emitJoin(eventId);
    debugPrint('Joined event chat: $eventId');
  }

  void leaveEvent(int eventId) {
    // удаляем намерение, чтобы при реконнекте не вступать снова
    _roomsToJoin.remove(eventId);

    if (_socket == null || !_isConnected) {
      return;
    }
    _socket!.emit('leaveEvent', eventId);
  }

  void sendMessage(int eventId, String messageText) {
    if (_socket == null || !_isConnected) {
      debugPrint('Socket not connected. Cannot send message.');
      return;
    }
    final messageData = {
      'eventId': eventId,
      'message': {'text': messageText}
    };
    _socket!.emit('sendMessage', messageData);
  }

  void listenToNewMessages(Function(MessageModel) onNewMessage) {
    _socket?.on('newMessage', (data) {
      onNewMessage(MessageModel.fromJson(data));
    });
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
