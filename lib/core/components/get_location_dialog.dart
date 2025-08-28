import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:neighbours/core/components/custom_gap.dart';
import 'package:neighbours/core/components/primary_button.dart';
import 'package:neighbours/core/cubits/user_location/user_location_cubit.dart';
import 'package:neighbours/core/extensions/context_ext.dart';

import 'custom_outlined_button.dart';

class GetLocationDialog extends StatelessWidget {
  const GetLocationDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          'Установите ваше местоположение,\nдля корректной работы приложения',
          style: context.text.bodyLarge.copyWith(
            color: context.color.secondaryText,
            fontWeight: FontWeight.w500,
          ),
          textAlign: TextAlign.center,
        ),
        const VerticalGap(24),
        PrimaryButton(
          text: 'Открыть настройки',
          onPressed: () => context.read<UserLocationCubit>().openSettings(),
          fontWeight: FontWeight.w400,
          verticalPadding: 14,
        ),
        const VerticalGap(8),
        CustomOutlinedButton(
          onPressed: () => context.pop(),
          text: 'Отмена',
        ),
        const VerticalGap(16),
      ],
    );
  }
}
