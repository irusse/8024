import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lottie/lottie.dart';
import 'package:neighbours/core/components/primary_button.dart';
import 'package:neighbours/core/constants/ui_constants.dart';
import 'package:neighbours/core/extensions/context_ext.dart';

import '../constants/assets.dart';
import 'custom_gap.dart';

class NotFoundPage extends StatelessWidget {
  final String? text;

  const NotFoundPage({super.key, this.text});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Padding(
      padding: const EdgeInsetsGeometry.symmetric(
          horizontal: UIConstants.defaultHorizontalPadding),
      child: Column(
        children: [
          VerticalGap(MediaQuery.of(context).size.height / 4.5),
          AspectRatio(
            aspectRatio: 1.4,
            child: Lottie.asset(Assets.lotties.notFound, repeat: false),
          ),
          Text(
            "Просим прощения",
            style: context.text.titleSmall,
          ),
          const VerticalGap(8),
          Text(
            text ?? "Запрашиваемая странице не найдена",
            style: context.text.bodyLarge
                .copyWith(color: context.color.secondaryText),
            textAlign: TextAlign.center,
          ),
          const VerticalGap(24),
          SizedBox(
            width: 180,
            child: PrimaryButton(
              text: 'Назад',
              onPressed: () => context.pop(),
              verticalPadding: 12,
            ),
          ),
          const VerticalGap(24)
        ],
      ),
    ));
  }
}
