import 'dart:async';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:injectable/injectable.dart';
import 'package:neighbours/core/data/models/app_notification/app_notification_model.dart';
import 'package:neighbours/core/di/injection.dart';
import 'package:neighbours/core/services/notification_service.dart';

@singleton
class FCMService {
  final _firebaseMessaging = FirebaseMessaging.instance;
  bool _isInitialized = false;

  final _tokenController = StreamController<String>.broadcast();

  Stream<String> get onTokenRefresh => _tokenController.stream;

  Future<void> init() async {
    try {
      if (_isInitialized) return;
      print('=========================');
      print('[FCM SERVICE] INIT');
      print('=========================');
      _isInitialized = true;
      await _firebaseMessaging.requestPermission();

      _initPushNotifications();
    } catch (err) {
      _isInitialized = false;
    }
  }

  Future<String?> getToken() async {
    final fcmToken = await _firebaseMessaging.getToken();
    return fcmToken;
  }

  // await getIt<FcmCubit>().saveFcmToken(fcmToken);
  // _firebaseMessaging.onTokenRefresh.listen((token) async {
  //   await getIt<FcmCubit>().saveFcmToken(token);
  // });

  void reset() {
    _isInitialized = false;
  }

  void _initPushNotifications() {
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
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
    print('=========================');
    print('[FCM SERVICE] Foreground message received');
    print('=========================');
    final notificationData = message.notification;
    if (notificationData != null) {
      getIt<NotificationService>().onNewNotification(message);
    }
  }

  /// Handles notification taps when the app is opened from the background or terminated state
  void _onMessageOpenedApp(RemoteMessage message) {
    print('=========================');
    print('[FCM SERVICE] Notification caused the app to open');
    print('=========================');
    final notificationModel = AppNotificationModel.fromRemoteMessage(message);
    if (notificationModel.payload == null) return;
    final payload = getIt<NotificationService>()
        .buildPayloadMap(notificationModel.payload!, notificationModel.type);
    getIt<NotificationService>().handleNotificationTap(payload);
  }
}

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  print('Background message received: ${message.data.toString()}');
}
