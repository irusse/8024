import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:injectable/injectable.dart';
import 'package:neighbours/core/cubits/fcm/fcm_cubit.dart';
import 'package:neighbours/core/data/models/app_notification/app_notification_model.dart';
import 'package:neighbours/core/di/injection.dart';
import 'package:neighbours/core/services/notification_service.dart';

@singleton
class FCMService {
  final _firebaseMessaging = FirebaseMessaging.instance;

  Future<void> init() async {
    await _firebaseMessaging.requestPermission();
    final fcmToken = await _firebaseMessaging.getToken();

    if (fcmToken == null) return;
    await getIt<FcmCubit>().saveFcmToken(fcmToken);
    _firebaseMessaging.onTokenRefresh.listen((token) async {
      await getIt<FcmCubit>().saveFcmToken(token);
    });

    _initPushNotifications();
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
