import 'package:injectable/injectable.dart';
import 'package:neighbours/core/router/app_router.dart';

import '../router/app_routes.dart';

@injectable
class NavigationService {
  final AppRouter _appRouter;

  NavigationService(this._appRouter);

  void goToLogin() {
    _appRouter.router.go(AppRoutePath.login);
  }
}
