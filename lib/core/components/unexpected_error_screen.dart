import 'package:flutter/material.dart';
import 'package:neighbours/core/extensions/context_ext.dart';

import '../constants/ui_constants.dart';
import 'custom_gap.dart';
import 'custom_outlined_button.dart';

class UnexpectedErrorScreen extends StatelessWidget {
  final VoidCallback onRetry;

  const UnexpectedErrorScreen({super.key, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        padding: const EdgeInsets.symmetric(
            horizontal: UIConstants.defaultHorizontalPadding),
        alignment: Alignment.center,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline_outlined,
              color: context.color.secondary,
              size: 56,
            ),
            const VerticalGap(16),
            Text(
              'Что-то пошло не так',
              style: context.text.bodyLarge,
            ),
            const VerticalGap(24),
            CustomOutlinedButton(onPressed: onRetry, text: 'Попробовать снова')
          ],
        ),
      ),
    );
  }
}
