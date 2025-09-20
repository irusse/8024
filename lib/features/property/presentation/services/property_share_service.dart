import '../../../../core/config/app_config.dart';
import '../../../../core/router/app_routes.dart';
import '../../../../core/services/share_service.dart';

class PropertyShareService {
  static shareProperty(int propertyId) {
    final shareLink = AppConfig.shareLink;
    final path = AppRouteBuilder.propertyDetails(propertyId);
    ShareService.shareLink("$shareLink$path");
  }
}
