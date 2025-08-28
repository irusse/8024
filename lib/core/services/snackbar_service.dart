import 'package:flutter/material.dart';
import 'package:injectable/injectable.dart';
import 'package:neighbours/core/components/custom_gap.dart';
import 'package:neighbours/core/extensions/context_ext.dart';
import 'dart:async';

enum SnackBarPosition {
  top,
  bottom,
}

class SnackbarController {
  final VoidCallback _dismiss;
  final Future<void> _closed;

  SnackbarController._(this._dismiss, this._closed);

  void dismiss() => _dismiss();

  Future<void> get closed => _closed;
}

abstract class SnackbarService {
  SnackbarController success(BuildContext context, String message);

  SnackbarController error(BuildContext context, String message,
      {SnackBarPosition position});

  SnackbarController info(BuildContext context, String message,
      {SnackBarPosition position});

  SnackbarController show(
    BuildContext context,
    String message, {
    Color? backgroundColor,
    Color? textColor,
    IconData? icon,
    Duration? duration,
    SnackBarPosition position,
  });
}

@Singleton(as: SnackbarService)
class SnackbarServiceImpl implements SnackbarService {
  static const defaultDuration = Duration(seconds: 2);

  @override
  SnackbarController success(BuildContext context, String message) {
    return show(
      context,
      message,
      backgroundColor: context.color.primary,
      icon: Icons.check_circle,
    );
  }

  @override
  SnackbarController error(BuildContext context, String message,
      {SnackBarPosition position = SnackBarPosition.bottom}) {
    return show(context, message,
        backgroundColor: context.color.basicRed,
        icon: Icons.error,
        position: position);
  }

  @override
  SnackbarController show(
    BuildContext context,
    String message, {
    Color? backgroundColor,
    Color? textColor,
    IconData? icon,
    Duration? duration,
    SnackBarPosition position = SnackBarPosition.bottom,
  }) {
    if (position == SnackBarPosition.bottom) {
      return _showBottomSnackbar(
        context,
        message,
        backgroundColor: backgroundColor,
        textColor: textColor,
        icon: icon,
        duration: duration,
      );
    } else {
      return _showTopSnackbar(
        context,
        message,
        backgroundColor: backgroundColor,
        textColor: textColor,
        icon: icon,
        duration: duration,
      );
    }
  }

  SnackbarController _showBottomSnackbar(
    BuildContext context,
    String message, {
    Color? backgroundColor,
    Color? textColor,
    IconData? icon,
    Duration? duration,
  }) {
    final scaffoldMessenger = ScaffoldMessenger.of(context);

    final snackBarController = scaffoldMessenger.showSnackBar(
      SnackBar(
        content: Row(
          children: [
            if (icon != null) ...[
              Icon(icon, color: textColor ?? Colors.white),
              const HorizontalGap(8),
            ],
            Expanded(
              child: Text(
                message,
                style: TextStyle(
                  color: textColor ?? Colors.white,
                ),
              ),
            ),
          ],
        ),
        backgroundColor: backgroundColor ?? Colors.grey.shade800,
        duration: duration ?? defaultDuration,
        behavior: SnackBarBehavior.fixed,
        shape: null,
      ),
    );

    return SnackbarController._(
      () => snackBarController.close(),
      snackBarController.closed,
    );
  }

  SnackbarController _showTopSnackbar(
    BuildContext context,
    String message, {
    Color? backgroundColor,
    Color? textColor,
    IconData? icon,
    Duration? duration,
  }) {
    final overlay = Overlay.of(context);
    late OverlayEntry overlayEntry;
    final completer = Completer<void>();

    overlayEntry = OverlayEntry(
      builder: (ctx) => Positioned(
        top: MediaQuery.of(context).padding.top + 24,
        left: 16,
        right: 16,
        child: Material(
          color: Colors.transparent,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: backgroundColor ?? Colors.grey.shade800,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                if (icon != null) ...[
                  Icon(icon, color: textColor ?? Colors.white),
                  const SizedBox(width: 8),
                ],
                Expanded(
                  child: Text(
                    message,
                    style: TextStyle(
                      color: textColor ?? Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );

    overlay.insert(overlayEntry);

    void removeEntry() {
      if (overlayEntry.mounted) {
        overlayEntry.remove();
        if (!completer.isCompleted) {
          completer.complete();
        }
      }
    }

    // Автоматическое удаление через заданное время
    Future.delayed(duration ?? defaultDuration, removeEntry);

    return SnackbarController._(removeEntry, completer.future);
  }

  @override
  SnackbarController info(BuildContext context, String message,
      {SnackBarPosition position = SnackBarPosition.bottom}) {
    return show(context, message,
        backgroundColor: context.color.secondary,
        icon: Icons.check_circle,
        textColor: context.color.primaryText,
        position: position);
  }
}
