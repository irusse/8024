import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:neighbours/core/components/custom_gap.dart';
import 'package:neighbours/core/components/custom_svg.dart';
import 'package:neighbours/core/components/primary_button.dart';
import 'package:neighbours/core/extensions/context_ext.dart';
import 'package:neighbours/core/router/app_routes.dart';

import '../../../../core/constants/assets.dart';

class AddEventDialog extends StatelessWidget {
  const AddEventDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          children: [
            _eventButton(context, onClick: () {
              context.pop();
              context.push(AppRoutePath.notificationForm);
            }, text: "Оповещение", iconPath: Assets.icons.bell),
            const HorizontalGap(8),
            _eventButton(context, onClick: () {
              context.pop();
              context.push(AppRoutePath.eventForm);
            }, text: "Мероприятие", iconPath: Assets.icons.stars),
          ],
        ),
        const VerticalGap(16),
        PrimaryButton(
          text: 'Отмена',
          onPressed: () {
            context.pop();
          },
        ),
      ],
    );
  }

  Widget _eventButton(BuildContext context,
      {required VoidCallback onClick,
      required String text,
      required String iconPath}) {
    return Expanded(
      child: GestureDetector(
        onTap: onClick,
        child: Container(
          height: 76,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            border: Border.all(width: 1, color: context.color.primary),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CustomSvg(asset: iconPath, color: context.color.primary),
              const VerticalGap(8),
              Text(
                text,
                style: context.text.bodyMedium.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
