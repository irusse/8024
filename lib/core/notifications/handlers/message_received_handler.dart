import 'package:injectable/injectable.dart';
import 'package:neighbours/core/extensions/router_ext.dart';
import 'package:neighbours/core/logging/logger.dart';

import '../../constants/notification_constants.dart';
import '../../di/injection.dart';
import '../../router/app_router.dart';
import '../../router/app_routes.dart';
import '../notification_handler.dart';

@Named(NotificationConstants.messageReceived)
@Singleton(as: NotificationHandler)
class MessageReceivedHandler implements NotificationHandler {
  @override
  String get type => NotificationConstants.messageReceived;

  @override
  void handle(Map<String, dynamic> payload) {
    final eventId = payload['eventId'] as int?;
    final communityId = payload['communityId'] as int?;
    final senderId = payload['senderId'] as int?;

    // Обрабатываем сообщения событий
    if (eventId != null) {
      final eventTitle = payload['eventTitle'] ?? 'Чат события';
      getIt<AppRouter>()
          .router
          .navigateUnique(AppRouteBuilder.eventChatPage(eventId, eventTitle));
      return;
    }

    // Обрабатываем сообщения сообществ
    if (communityId != null) {
      final communityTitle = payload['communityTitle'] ?? 'Чат сообщества';
      getIt<AppRouter>().router.navigateUnique(
          AppRouteBuilder.communityChatPage(communityId, communityTitle));
      return;
    }
    // Обрабатываем сообщения приватных чатов
    if (senderId != null) {
      AppLogger.info(payload.toString());
      getIt<AppRouter>().router.navigateUnique(AppRouteBuilder.privateChatPage(
            senderId,
          ));
      return;
    }
  }
}
