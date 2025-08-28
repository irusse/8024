import 'package:chucker_flutter/chucker_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:neighbours/core/cubits/theme/theme_cubit.dart';
import 'package:neighbours/core/services/notification_service.dart';
import 'core/di/injection.dart';
import 'core/router/app_router.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'core/themes/theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  ChuckerFlutter.showOnRelease = true;
  ChuckerFlutter.showNotification = true;

  await dotenv.load();
  await configureDependencies();
  await getIt<NotificationService>().init();
  runApp(BlocProvider.value(
    value: getIt<ThemeCubit>()..loadTheme(),
    child: const MyApp(),
  ));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    final appRouter = getIt<AppRouter>();
    return BlocSelector<ThemeCubit, ThemeState, bool>(
      selector: (state) => state.isDark,
      builder: (context, isDark) {
        return MaterialApp.router(
          title: 'Тучат',
          debugShowCheckedModeBanner: false,
          theme: createLightTheme(),
          darkTheme: createDarkTheme(),
          themeMode: isDark ? ThemeMode.dark : ThemeMode.light,
          routerConfig: appRouter.router,
          localizationsDelegates: GlobalMaterialLocalizations.delegates,
          supportedLocales: const [
            Locale('ru', 'RU'),
          ],
          builder: (context, child) {
            return ScreenUtilInit(
              designSize: const Size(375, 812),
              minTextAdapt: true,
              splitScreenMode: true,
              builder: (context, _) => child!,
            );
          },
        );
      },
    );
  }
}

Future<void> mainWithEnv(
    {required String baseUrl, required String mabBox}) async {
  // BASE_URL будет подхвачен через dart-define
  main();
}
