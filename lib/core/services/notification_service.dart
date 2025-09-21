import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:injectable/injectable.dart';
import 'package:neighbours/core/constants/notification_constants.dart';
import 'package:neighbours/core/data/models/app_notification/app_notification_model.dart';
import 'package:neighbours/core/di/injection.dart';
import '../notifications/notification_handler.dart';

@singleton
class NotificationService {
  final _notificationPlugin = FlutterLocalNotificationsPlugin();

  bool _isInitialized = false;

  final _controller = StreamController<AppNotificationModel>.broadcast();

  Stream<AppNotificationModel> get stream => _controller.stream;

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
          handleNotificationTap(jsonDecode(response.payload!));
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

    _controller.add(appNotificationModel);

    // показываем только "системные" уведомления сразу
    if (appNotificationModel.type != NotificationConstants.messageReceived) {
      showBasicNotification(appNotificationModel);
    }
  }

  Future<void> showBasicNotification(AppNotificationModel notification) async {
    if (notification.payload == null || notification.payload!.isEmpty) {
      return Future.value();
    }

    await _notificationPlugin.show(
      notification.hashCode,
      notification.title,
      notification.body,
      _notificationDetails(),
      payload:
          jsonEncode(buildPayloadMap(notification.payload!, notification.type)),
    );
  }

  Map<String, dynamic> buildPayloadMap(String payload, String type) {
    final payloadMap = jsonDecode(payload) as Map<String, dynamic>;
    payloadMap["type"] = type;
    return payloadMap;
  }

  NotificationDetails _notificationDetails() {
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

  void handleNotificationTap(Map<String, dynamic> payload) {
    final type = payload["type"];
    if (type == null) return;

    final handler = getIt<NotificationHandler>(instanceName: type);
    handler.handle(payload);
  }
}
