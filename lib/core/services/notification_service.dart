import 'dart:convert';
import 'dart:io';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:injectable/injectable.dart';
import 'package:neighbours/core/constants/notification_constants.dart';
import 'package:neighbours/core/data/models/app_notification/app_notification_model.dart';
import 'package:neighbours/core/di/injection.dart';
import 'package:neighbours/core/router/app_router.dart';
import 'package:neighbours/core/router/app_routes.dart';

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

    _showBasicNotification(appNotificationModel);
  }

  Future<void> _showBasicNotification(AppNotificationModel notification) {
    if (notification.payload == null || notification.payload!.isEmpty) {
      return Future.value();
    }

    return _notificationPlugin.show(
      notification.hashCode,
      notification.title,
      notification.body,
      _chatNotificationDetails(),
      payload:
          jsonEncode(buildPayloadMap(notification.payload!, notification.type)),
    );
  }

  Map<String, dynamic> buildPayloadMap(String payload, String type) {
    final payloadMap = jsonDecode(payload) as Map<String, dynamic>;
    payloadMap["type"] = type;
    return payloadMap;
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

  void handleNotificationTap(Map<String, dynamic> payload) {
    final type = payload["type"]!;
    switch (type) {
      case NotificationConstants.eventCreated:
      case NotificationConstants.userLeftEvent:
      case NotificationConstants.userJoinedEvent:
        {
          int? eventId = payload['eventId'];
          if (eventId == null) return;
          getIt<AppRouter>().router.push(AppRouteBuilder.eventDetails(eventId));
        }
    }
  }
}
