import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:neighbours/core/components/primary_button.dart';
import 'package:neighbours/core/constants/assets.dart';
import 'package:neighbours/core/extensions/context_ext.dart';

import '../constants/ui_constants.dart';
import 'custom_gap.dart';

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
            VerticalGap(MediaQuery.of(context).size.height / 4),
            AspectRatio(
              aspectRatio: 1.6,
              child: Lottie.asset(Assets.lotties.warning, repeat: false),
            ),
            const VerticalGap(32),
            Text(
              'Упссс..',
              style: context.text.titleSmall,
            ),
            const VerticalGap(8),
            Text(
              'Похоже, произошла ошибка. Давайте попробуем снова!',
              style: context.text.bodyLarge
                  .copyWith(color: context.color.secondaryText),
              textAlign: TextAlign.center,
            ),
            const Spacer(),
            PrimaryButton(
                verticalPadding: 16,
                onPressed: onRetry,
                text: 'Попробовать снова'),
            const VerticalGap(48)
          ],
        ),
      ),
    );
  }
}
