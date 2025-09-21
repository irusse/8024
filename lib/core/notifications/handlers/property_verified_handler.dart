import 'package:injectable/injectable.dart';
import 'package:neighbours/core/extensions/router_ext.dart';
import 'package:neighbours/core/router/app_router.dart';

import '../../constants/notification_constants.dart';
import '../../di/injection.dart';
import '../../router/app_routes.dart';
import '../notification_handler.dart';

@Named(NotificationConstants.propertyVerified)
@Singleton(as: NotificationHandler)
class PropertyVerifiedHandler implements NotificationHandler {
  @override
  String get type => NotificationConstants.propertyVerified;

  @override
  void handle(Map<String, dynamic> payload) {
    final propertyId = payload['propertyId'] as int?;
    if (propertyId == null) return;

    getIt<AppRouter>()
        .router
        .navigateUnique(AppRouteBuilder.propertyDetails(propertyId));
  }
}
