import 'dart:convert';
import 'dart:io';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:injectable/injectable.dart';
import 'package:neighbours/core/data/models/app_notification/app_notification_model.dart';

@singleton
class NotificationService {
  final _notificationPlugin = FlutterLocalNotificationsPlugin();
  bool _isInitialized = false;

  Future<void> init() async {
    if (_isInitialized) return;
    const initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const initializationSettingsIOS = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const InitializationSettings initializationSettings =
        InitializationSettings(
            android: initializationSettingsAndroid,
            iOS: initializationSettingsIOS);

    await _notificationPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: (NotificationResponse response) {
        if (response.payload != null) {
          final data = jsonDecode(response.payload!);
          print("Daaaaa");
          print("================");
          // _handleNotificationTap();
        }
      },
    );

    if (Platform.isAndroid) {
      final androidImplementation =
          _notificationPlugin.resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>();

      final granted =
          await androidImplementation?.requestNotificationsPermission();
      debugPrint('Notification permission granted: $granted');
    }

    if (Platform.isIOS) {
      final iosImplementation =
          _notificationPlugin.resolvePlatformSpecificImplementation<
              IOSFlutterLocalNotificationsPlugin>();

      await iosImplementation?.requestPermissions(
        alert: true,
        badge: true,
        sound: true,
      );
    }

    _isInitialized = true;
  }

  void onNewNotification(RemoteMessage? message) {
    if (message == null) return;
    final appNotificationModel =
        AppNotificationModel.fromRemoteMessage(message);

    _showBasicNotification(appNotificationModel);
  }

  Future<void> _showBasicNotification(AppNotificationModel notification) {
    if (notification.payload == null || notification.payload!.isEmpty) {
      return Future.value();
    }

    Map<String, dynamic> payloadMap = {};
    payloadMap = jsonDecode(notification.payload!) as Map<String, dynamic>;
    payloadMap["type"] = notification.type;

    return _notificationPlugin.show(
      notification.hashCode,
      notification.title,
      notification.body,
      _chatNotificationDetails(),
      payload: jsonEncode(payloadMap),
    );
  }

  NotificationDetails _chatNotificationDetails() {
    return const NotificationDetails(
        android: AndroidNotificationDetails('chat_channel', 'Чат',
            channelDescription: 'Уведомления о новых сообщениях в чате',
            importance: Importance.high,
            priority: Priority.high,
            icon: '@mipmap/ic_launcher'),
        iOS: DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ));
  }

  void _handleNotificationTap(Map<String, dynamic> payload) {
    final type = payload["type"]!;
    // switch (type){
    //   case NotificationConstants.userJoinedEvent
    // }
    // getIt<AppRouter>()
    //     .router
    //     .push(AppRouteBuilder.chatPage(int.parse(eventId), eventTitle));
  }
}
