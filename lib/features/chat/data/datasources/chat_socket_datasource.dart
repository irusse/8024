import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:injectable/injectable.dart';
import 'package:neighbours/core/data/models/message/message_model.dart';
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

  io.Socket? get socket => _socket;

  // Вызываем один раз при старте приложения (после DI setup)
  Future<void> initializeSocket() async {
    // подписка на изменения токена
    _tokenSub ??= _authService.accessTokenStream.listen((token) async {
      if (token == null || token.isEmpty) {
        // нет токена → гарантированно отключаемся
        _teardownSocket();
        return;
      }
      // есть новый токен → переподключаемся с новым query
      await _reconnectWithToken(token);
    });

    // первичная инициализация, если токен уже есть
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
        .setReconnectionAttempts(5)
        .setReconnectionDelay(1000)
        .setReconnectionDelayMax(5000)
        .setTimeout(20000)
        .setQuery({'token': token, 'EIO': '4'})
        .enableForceNew()
        .build();

    _socket = io.io(
      AppConfig.socketUrl,
      opts,
    );
    _setupSocketListeners();
    _socket!.connect(); // вручную подключаемся
  }

  void _setupSocketListeners() {
    _socket?.onConnect((_) {
      _isConnected = true;
    });

    _socket?.onDisconnect((_) {
      _isConnected = false;
    });

    _socket?.onConnectError((error) {
      _isConnected = false;
    });

    _socket?.onError((error) {});

    _socket?.on('connected', (data) {});
  }

  void joinEvent(int eventId) {
    if (_socket == null || !_isConnected) {
      debugPrint('Socket not connected. Cannot join event.');
      return;
    }
    _socket!.emit('joinEvent', eventId);
    debugPrint('Joined event chat: $eventId');
  }

  void sendMessage(int eventId, String messageText) {
    if (_socket == null || !_isConnected) {
      debugPrint('Socket not connected. Cannot send message.');
      return;
    }
    final messageData = {
      'eventId': eventId,
      'message': {
        'text': messageText,
      }
    };
    _socket!.emit('sendMessage', messageData);
  }

  void listenToNewMessages(Function(MessageModel) onNewMessage) {
    if (_socket == null) {
      return;
    }
    _socket!.on('newMessage', (data) {
      onNewMessage(MessageModel.fromJson(data));
    });
  }

  void leaveEvent(int eventId) {
    if (_socket == null || !_isConnected) {
      return;
    }
    _socket!.emit('leaveEvent', eventId);
  }

  void disconnect() {
    _teardownSocket();
    _tokenSub?.cancel();
    _tokenSub = null;
  }

  void _teardownSocket() {
    try {
      _socket?.disconnect();
      _socket?.dispose();
    } catch (_) {}
    _socket = null;
    _isConnected = false;
  }
}
