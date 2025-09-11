import 'package:flutter/material.dart';
import 'package:neighbours/core/extensions/context_ext.dart';

import '../../../../core/components/custom_gap.dart';
import '../../../../core/components/custom_outlined_button.dart';
import '../../../../core/constants/ui_constants.dart';

class ErrorWithTryBtn extends StatelessWidget {
  final String error;
  final VoidCallback onErrorClick;

  const ErrorWithTryBtn(
      {super.key, required this.error, required this.onErrorClick});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
          horizontal: UIConstants.defaultHorizontalPadding),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              error,
              style: context.text.bodyLarge
                  .copyWith(color: context.color.basicRed),
              textAlign: TextAlign.center,
            ),
            const VerticalGap(16),
            SizedBox(
              width: 220,
              child: CustomOutlinedButton(
                  verticalPadding: 12,
                  onPressed: onErrorClick,
                  text: "Попробовать ещё раз"),
            )
          ],
        ),
      ),
    );
  }
}
