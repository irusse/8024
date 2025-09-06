import 'dart:convert';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:neighbours/core/constants/notification_constants.dart';

class AppNotificationModel {
  final String title;
  final String body;
  final String type;
  final String? payload;

  AppNotificationModel({
    required this.title,
    required this.body,
    required this.type,
    this.payload,
  });

  factory AppNotificationModel.fromRemoteMessage(RemoteMessage message) {
    return AppNotificationModel(
      title: message.notification?.title ?? "Неизвестно",
      body: message.notification?.body ?? "Неизвестно",
      type: message.data["type"] ?? NotificationConstants.undefined,
      payload: message.data["payload"],
    );
  }
}
