import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:neighbours/core/extensions/context_ext.dart';
import '../../../../core/components/custom_button.dart';
import '../cubits/home/home_cubit.dart';

class AddEventButton extends StatelessWidget {
  const AddEventButton({super.key});

  @override
  Widget build(BuildContext context) {
    return CustomButton(
      onPressed: () => context.read<HomeCubit>().handleEventStepNavigation(),
      height: 48,
      width: 48,
      style: BoxDecoration(
        color: context.color.primary,
        shape: BoxShape.circle,
      ),
      icon: const Icon(Icons.add, color: Colors.white),
    );
  }
}
