import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:injectable/injectable.dart';
import 'package:neighbours/core/cubits/fcm/fcm_cubit.dart';
import 'package:neighbours/core/di/injection.dart';
import 'package:neighbours/core/services/notification_service.dart';

@singleton
class FCMService {
  final _firebaseMessaging = FirebaseMessaging.instance;

  Future<void> init() async {
    await _firebaseMessaging.requestPermission();
    final fcmToken = await _firebaseMessaging.getToken();
    if (fcmToken == null) return;
    getIt<FcmCubit>().saveFcmToken(fcmToken);
    _initPushNotifications();
  }

  void _initPushNotifications() {
    // FirebaseMessaging.instance.getInitialMessage().then(handleMessage);
    // FirebaseMessaging.onMessageOpenedApp.listen(handleMessage);
    FirebaseMessaging.onMessage
        .listen(getIt<NotificationService>().onNewNotification);
  }
}
