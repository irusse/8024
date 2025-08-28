import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class SheetUtils {
  static Future<void> ensureBottomSheetClosed(BuildContext context) async {
    if (context.canPop()) {
      context.pop();
      await Future.delayed(const Duration(milliseconds: 200));
    }
  }
}