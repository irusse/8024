import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:neighbours/core/extensions/context_ext.dart';
import '../../../../core/di/injection.dart';
import '../../../../core/router/app_routes.dart';
import '../../../../core/services/auth_service.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2), // время появления
    );
    _animation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeIn,
    );
    _checkAuth();
  }

  Future<void> _checkAuth() async {
    _controller.forward();
    final authService = getIt<AuthService>();

    final hasTokenFuture = authService.hasToken();

    final results = await Future.wait([
      hasTokenFuture,
      Future.delayed(const Duration(seconds: 4)),
    ]);

    final hasToken = results[0] as bool;

    if (!mounted) return;

    if (hasToken) {
      context.go(AppRoutePath.home);
    } else {
      context.go(AppRoutePath.authWelcome);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
          child: FadeTransition(
        opacity: _animation,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              '8024',
              style: context.text.titleLarge
                  .copyWith(fontWeight: FontWeight.w500, fontSize: 56),
            ),
            Text(
              'Гиперлокальная сеть',
              style: context.text.bodyLarge,
            )
          ],
        ),
      )),
    );
  }
}
