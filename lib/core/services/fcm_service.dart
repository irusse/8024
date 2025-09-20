import 'dart:async';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:injectable/injectable.dart';
import 'package:neighbours/core/data/models/app_notification/app_notification_model.dart';
import 'package:neighbours/core/di/injection.dart';
import 'package:neighbours/core/logging/logger.dart';
import 'package:neighbours/core/services/notification_service.dart';

@singleton
class FCMService {
  final _firebaseMessaging = FirebaseMessaging.instance;
  bool _isInitialized = false;

  final _tokenController = StreamController<String>.broadcast();

  Stream<String> get onTokenRefresh => _tokenController.stream;
  final String _tag = "FCM SERVICE";

  Future<void> init() async {
    try {
      if (_isInitialized) return;
      AppLogger.info("INITIALIZING", tag: _tag);
      _isInitialized = true;
      await _firebaseMessaging.requestPermission();
      _initPushNotifications();

      final token = await _firebaseMessaging.getToken();
      if (token != null) {
        _tokenController.add(token);
      }
      FirebaseMessaging.instance.onTokenRefresh.listen((newToken) {
        AppLogger.debug("TOKEN REFRESHED", tag: _tag);
        _tokenController.add(newToken);
      });
    } catch (err) {
      _isInitialized = false;
    }
  }

  Future<String?> getToken() async {
    final fcmToken = await _firebaseMessaging.getToken();
    return fcmToken;
  }

  void reset() {
    _isInitialized = false;
  }

  void _initPushNotifications() {
    FirebaseMessaging.onMessageOpenedApp.listen(_onMessageOpenedApp);
    FirebaseMessaging.onMessage.listen(_onForegroundMessage);
    FirebaseMessaging.instance.getInitialMessage().then((message) {
      if (message != null) {
        _onMessageOpenedApp(message);
      }
    });
  }

  /// Handles message received while the app is in the background
  void _onForegroundMessage(RemoteMessage message) {
    AppLogger.info("New Foreground message", tag: _tag);
    final notificationData = message.notification;
    if (notificationData != null) {
      getIt<NotificationService>().onNewNotification(message);
    }
  }

  /// Handles notification taps when the app is opened from the background or terminated state
  void _onMessageOpenedApp(RemoteMessage message) {
    AppLogger.info("Notification tapped", tag: _tag);
    final notificationModel = AppNotificationModel.fromRemoteMessage(message);
    if (notificationModel.payload == null) return;
    final payload = getIt<NotificationService>()
        .buildPayloadMap(notificationModel.payload!, notificationModel.type);
    getIt<NotificationService>().handleNotificationTap(payload);
  }
}
