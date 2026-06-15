import 'package:neighbours/core/config/app_config.dart';

import '../../../../core/router/app_routes.dart';
import '../../../../core/services/share_service.dart';

class EventShareService {
  static shareEvent(int eventId) {
    final shareLink = AppConfig.shareLink;
    final path = AppRouteBuilder.eventDetails(eventId);
    ShareService.shareLink("$shareLink$path");
  }
}
