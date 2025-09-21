
import 'package:injectable/injectable.dart';
import 'package:neighbours/core/extensions/router_ext.dart';

import '../../constants/notification_constants.dart';
import '../../di/injection.dart';
import '../../router/app_router.dart';
import '../../router/app_routes.dart';
import '../notification_handler.dart';

@Named(NotificationConstants.userJoinedEvent)
@Singleton(as: NotificationHandler)
class EventJoinedHandler implements NotificationHandler {
  @override
  String get type => NotificationConstants.userJoinedEvent;

  @override
  void handle(Map<String, dynamic> payload) {
    final eventId = payload['eventId'] as int?;
    if (eventId == null) return;
    getIt<AppRouter>()
        .router
        .navigateUnique(AppRouteBuilder.eventDetails(eventId));
  }
}
