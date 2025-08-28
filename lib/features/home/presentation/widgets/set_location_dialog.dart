import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:neighbours/core/components/custom_gap.dart';
import 'package:neighbours/core/components/custom_outlined_button.dart';
import 'package:neighbours/core/components/primary_button.dart';
import 'package:neighbours/core/extensions/context_ext.dart';
import 'package:neighbours/features/home/presentation/cubits/home/home_cubit.dart';

class SetCoordinates extends StatelessWidget {
  final VoidCallback onClick;

  const SetCoordinates({super.key, required this.onClick});

  @override
  Widget build(BuildContext context) {
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: IgnorePointer(
        ignoring: false,
        child: Container(
          decoration: BoxDecoration(
            color: context.color.background,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(8)),
          ),
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Выберите точку на карте', style: context.text.bodyLarge),
              const VerticalGap(16),
              PrimaryButton(
                text: 'Подтвердить',
                onPressed: onClick,
              ),
              const VerticalGap(8),
              CustomOutlinedButton(
                onPressed: () =>
                    context.read<HomeCubit>().goToAddPropertyStep(),
                verticalPadding: 14,
                text: 'Назад',
              )
            ],
          ),
        ),
      ),
    );
  }
}
