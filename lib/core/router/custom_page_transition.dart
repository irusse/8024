import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class CustomPageTransition<T> extends CustomTransitionPage<T> {
  const CustomPageTransition({
    required Widget child,
    super.key,
    Duration duration = const Duration(milliseconds: 300),
    required TransitionsBuilder transitionsBuilder,
  }) : super(
          child: child,
          transitionDuration: duration,
          transitionsBuilder: transitionsBuilder,
        );

  factory CustomPageTransition.slideFromRight(
      {required Widget child, LocalKey? key}) {
    return CustomPageTransition(
      child: child,
      transitionsBuilder: slideFromRight,
    );
  }

  factory CustomPageTransition.slideFromLeft(
      {required Widget child, LocalKey? key}) {
    return CustomPageTransition(
      child: child,
      transitionsBuilder: slideFromLeft,
    );
  }

  factory CustomPageTransition.fade({required Widget child, LocalKey? key}) {
    return CustomPageTransition(
      key: key,
      child: child,
      transitionsBuilder: fadeIn,
    );
  }

  factory CustomPageTransition.slideFromBottom(
      {required Widget child, LocalKey? key}) {
    return CustomPageTransition(
      key: key,
      child: child,
      transitionsBuilder: slideFromBottom,
    );
  }
}

typedef TransitionsBuilder = Widget Function(
  BuildContext,
  Animation<double>,
  Animation<double>,
  Widget,
);

Widget slideFromRight(
  BuildContext context,
  Animation<double> animation,
  Animation<double> secondaryAnimation,
  Widget child,
) {
  return SlideTransition(
    position: animation.drive(Tween(begin: const Offset(1, 0), end: Offset.zero)
        .chain(CurveTween(curve: Curves.easeOutCubic))),
    child: child,
  );
}

Widget slideFromLeft(
  BuildContext context,
  Animation<double> animation,
  Animation<double> secondaryAnimation,
  Widget child,
) {
  return SlideTransition(
    position: animation.drive(
      Tween<Offset>(
        begin: const Offset(-1, 0), // -1 по X = слева
        end: Offset.zero,
      ).chain(
        CurveTween(curve: Curves.easeOutCubic),
      ),
    ),
    child: child,
  );
}

Widget slideFromBottom(
  BuildContext context,
  Animation<double> animation,
  Animation<double> secondaryAnimation,
  Widget child,
) {
  return SlideTransition(
    position: animation.drive(
      Tween<Offset>(
        begin: const Offset(0, 1), // снизу (по Y)
        end: Offset.zero,
      ).chain(
        CurveTween(curve: Curves.easeOutCubic),
      ),
    ),
    child: child,
  );
}

Widget fadeIn(
  BuildContext context,
  Animation<double> animation,
  Animation<double> secondaryAnimation,
  Widget child,
) {
  return FadeTransition(opacity: animation, child: child);
}
