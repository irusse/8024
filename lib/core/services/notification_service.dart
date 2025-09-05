import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:injectable/injectable.dart';
import 'package:neighbours/core/cubits/events/events_cubit.dart';
import 'package:neighbours/core/di/injection.dart';
import 'package:neighbours/core/domain/entities/event/event_entity.dart';
import 'package:neighbours/core/router/app_router.dart';
import 'package:neighbours/core/router/app_routes.dart';
import 'package:neighbours/features/chat/domain/entities/message/message_entity.dart';

@singleton
class NotificationService {
  final notificationPlugin = FlutterLocalNotificationsPlugin();
  bool _isInitialized = false;

  bool get isInitialized => _isInitialized;

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

    await notificationPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: (NotificationResponse response) {
        if (response.payload != null) {
          final data = jsonDecode(response.payload!);
          final eventId = data["eventId"];
          final eventTitle = data["eventTitle"];

          _handleNotificationTap(eventId, eventTitle);
        }
      },
    );

    if (Platform.isAndroid) {
      final androidImplementation =
          notificationPlugin.resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>();

      final granted =
          await androidImplementation?.requestNotificationsPermission();
      debugPrint('Notification permission granted: $granted');
    }

    if (Platform.isIOS) {
      final iosImplementation =
          notificationPlugin.resolvePlatformSpecificImplementation<
              IOSFlutterLocalNotificationsPlugin>();

      await iosImplementation?.requestPermissions(
        alert: true,
        badge: true,
        sound: true,
      );
    }

    _isInitialized = true;
  }

  void _handleNotificationTap(String eventId, String eventTitle) {
    getIt<AppRouter>()
        .router
        .push(AppRouteBuilder.chatPage(int.parse(eventId), eventTitle));
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

  /// Показывает уведомление о новом сообщении в событии
  Future<void> showEventMessageNotification(MessageEntity message) async {
    final eventsCubit = getIt<EventsCubit>();
    final event = eventsCubit.state.events[message.eventId] ??
        eventsCubit.state.notifications[message.eventId];
    String eventTitle = "Чат";
    if (event != null) {
      eventTitle = event.title;
    }
    final title = event is FullEvent
        ? 'Мероприятие "$eventTitle"'
        : 'Оповещение "$eventTitle"';
    final body =
        '${message.user.firstName}: ${message.text.length > 25 ? "${message.text.substring(0, 25)}..." : message.text}';
    return notificationPlugin.show(
      message.id.hashCode,
      title,
      body,
      _chatNotificationDetails(),
      payload: jsonEncode({
        "eventId": message.eventId.toString(),
        "eventTitle": eventTitle,
      }),
    );
  }
}
