import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:neighbours/core/extensions/context_ext.dart';
import 'package:neighbours/core/services/snackbar_service.dart';

class ClipboardService {
  static Future<void> copyToClipboard({
    required BuildContext context,
    required String text,
    String successMessage = 'Скопировано в буфер обмена',
    SnackBarPosition position = SnackBarPosition.bottom,
  }) async {
    HapticFeedback.lightImpact();
    await Clipboard.setData(ClipboardData(text: text));

    if (context.mounted) {
      context.snackbar.info(
        context,
        successMessage,
        position: position,
      );
    }
  }
}
