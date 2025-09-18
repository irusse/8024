import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:neighbours/core/cubits/fcm/fcm_cubit.dart';
import 'package:neighbours/core/cubits/theme/theme_cubit.dart';
import 'package:neighbours/core/data/models/app_notification/app_notification_model.dart';
import 'package:neighbours/core/services/notification_service.dart';
import 'core/di/injection.dart';
import 'core/router/app_router.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'core/themes/theme.dart';
import 'firebase_options.dart';

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  final notificationService = getIt<NotificationService>();
  final model = AppNotificationModel.fromRemoteMessage(message);
  await notificationService.showBasicNotification(model);
  debugPrint('=========================');
  debugPrint('[MAIN] Handling a background message');
  debugPrint('=========================');
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  await dotenv.load();
  await configureDependencies();

  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  await getIt<FcmCubit>().initFCM();
  await getIt<NotificationService>().init();
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  runApp(BlocProvider.value(
    value: getIt<ThemeCubit>()..loadTheme(),
    child: const MyApp(),
  ));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final appRouter = getIt<AppRouter>();
    return BlocSelector<ThemeCubit, ThemeState, bool>(
      selector: (state) => state.isDark,
      builder: (context, isDark) {
        return MaterialApp.router(
          title: '8024',
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
