import '../../../../core/config/app_config.dart';
import '../../../../core/router/app_routes.dart';
import '../../../../core/services/share_service.dart';

class OtherProfileShareService {
  static shareEvent(int userId) {
    final shareLink = AppConfig.shareLink;
    final path = AppRouteBuilder.otherProfile(userId);
    ShareService.shareLink("$shareLink$path");
  }
}
