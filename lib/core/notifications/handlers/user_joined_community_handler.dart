import 'package:injectable/injectable.dart';
import 'package:neighbours/core/extensions/router_ext.dart';

import '../../constants/notification_constants.dart';
import '../../di/injection.dart';
import '../../router/app_router.dart';
import '../../router/app_routes.dart';
import '../notification_handler.dart';

@Named(NotificationConstants.userJoinedCommunity)
@Singleton(as: NotificationHandler)
class UserJoinedCommunityHandler implements NotificationHandler {
  @override
  String get type => NotificationConstants.userJoinedCommunity;

  @override
  void handle(Map<String, dynamic> payload) {
    final communityId = payload['communityId'] as int?;
    if (communityId == null) return;
    getIt<AppRouter>()
        .router
        .navigateUnique(AppRouteBuilder.community(communityId));
  }
}
