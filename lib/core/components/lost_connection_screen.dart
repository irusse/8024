import 'package:flutter/material.dart';
import 'package:neighbours/core/components/custom_gap.dart';
import 'package:neighbours/core/components/custom_outlined_button.dart';
import 'package:neighbours/core/constants/ui_constants.dart';
import 'package:neighbours/core/extensions/context_ext.dart';

class LostConnectionScreen extends StatelessWidget {
  final VoidCallback onRetry;

  const LostConnectionScreen({super.key, required this.onRetry});

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
              Icons.wifi_off_outlined,
              color: context.color.secondary,
              size: 56,
            ),
            const VerticalGap(16),
            Text(
              'Отсутсвует подключение к интернету',
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
