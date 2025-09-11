import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:injectable/injectable.dart';
import 'package:neighbours/core/constants/notification_constants.dart';
import 'package:neighbours/core/cubits/events/events_cubit.dart';
import 'package:neighbours/core/data/models/app_notification/app_notification_model.dart';
import 'package:neighbours/core/di/injection.dart';
import 'package:neighbours/core/domain/entities/event/event_entity.dart';
import 'package:neighbours/core/router/app_router.dart';
import 'package:neighbours/core/router/app_routes.dart';
import 'package:neighbours/features/chat/domain/entities/message/message_entity.dart';

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

    _showBasicNotification(appNotificationModel);
    _controller.add(appNotificationModel);
  }

  Future<void> _showBasicNotification(AppNotificationModel notification) async {
    if (notification.payload == null || notification.payload!.isEmpty) {
      return Future.value();
    }

    await _notificationPlugin.show(
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
      case NotificationConstants.messageReceived:
        {
          int? eventId = payload['eventId'];
          if (eventId == null) return;
          getIt<AppRouter>()
              .router
              .push(AppRouteBuilder.chatPage(eventId, payload['eventTitle']));
          break;
        }
      case NotificationConstants.userJoinedCommunity:
        {
          int? communityId = payload['communityId'];
          if (communityId == null) return;
          getIt<AppRouter>()
              .router
              .push(AppRouteBuilder.community(communityId));
          break;
        }
      case NotificationConstants.propertyVerified:
        {
          int? propertyId = payload['propertyId'];
          if (propertyId == null) return;
          getIt<AppRouter>()
              .router
              .push(AppRouteBuilder.propertyDetails(propertyId));
          break;
        }
      case NotificationConstants.eventCreated:
      case NotificationConstants.userLeftEvent:
      case NotificationConstants.userJoinedEvent:
        {
          int? eventId = payload['eventId'];
          if (eventId == null) return;
          getIt<AppRouter>().router.push(AppRouteBuilder.eventDetails(eventId));
          break;
        }
    }
  }
//
// Future<void> showEventMessageNotification(MessageEntity message) async {
//   final eventsCubit = getIt<EventsCubit>();
//   final event = eventsCubit.state.events[message.eventId];
//   if (event == null) return;
//   String eventTitle = "Чат";
//
//   final title = event.isFullEvent
//       ? 'Мероприятие "$eventTitle"'
//       : 'Оповещение "$eventTitle"';
//   final body =
//       '${message.user.firstName}: ${message.text.length > 25 ? "${message.text.substring(0, 25)}..." : message.text}';
//   return _notificationPlugin.show(
//     message.id.hashCode,
//     title,
//     body,
//     _chatNotificationDetails(),
//     payload: jsonEncode({
//       "eventId": message.eventId,
//       "eventTitle": eventTitle,
//       "type": NotificationConstants.messageReceived
//     }),
//   );
// }
}
