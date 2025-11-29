import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:neighbours/core/components/custom_gap.dart';
import 'package:neighbours/core/cubits/user/user_cubit.dart';
import 'package:neighbours/core/extensions/context_ext.dart';
import 'package:neighbours/core/router/app_routes.dart';
import 'package:neighbours/features/home/domain/enums/map_display_mode.dart';
import 'package:neighbours/features/property/presentation/cubits/properties/properties_cubit.dart';

import '../cubits/home/home_cubit.dart';

class BottomPanel extends StatelessWidget {
  final Function(double, double) navigateToProperty;

  const BottomPanel({super.key, required this.navigateToProperty});

  void _onHomeClick(BuildContext context) {
    final homeCubit = context.read<HomeCubit>();
    final userId = context.read<UserCubit>().state.user.id;
    final property = context.read<PropertiesCubit>().getMyProperty(userId);
    
    if (property == null) {
      homeCubit
        ..setIdle()
        ..goToAddPropertyStep();
    } else {
      // Есть недвижимость - показываем только слой недвижимости
      homeCubit.showOnlyProperty();
    }
  }

  void _onAllClick(BuildContext context) {
    context.read<HomeCubit>().showAllLayers();
  }

  void _onPlanBClick(BuildContext context) {
    context.read<HomeCubit>().showOnlyPlanB();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<HomeCubit, HomeState>(
      builder: (context, state) {
        final displayMode = context.read<HomeCubit>().displayMode;
        
        return SizedBox(
          height: 36,
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                const HorizontalGap(8),
                _buildNavButton(
                  context,
                  icon: Icons.home_filled,
                  isActive: displayMode == MapDisplayMode.propertyOnly,
                  onTap: () => _onHomeClick(context),
                ),
                _buildNavButton(
                  context,
                  label: 'Все',
                  isActive: displayMode == MapDisplayMode.all,
                  onTap: () => _onAllClick(context),
                ),
                _buildNavButton(
                  context,
                  label: 'План Б',
                  isActive: displayMode == MapDisplayMode.planBOnly,
                  onTap: () => _onPlanBClick(context),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

Widget _buildNavButton(
  BuildContext context, {
  required VoidCallback onTap,
  IconData? icon,
  String? label,
  bool isActive = false,
}) {
  return GestureDetector(
    onTap: onTap,
    child: Container(
      margin: const EdgeInsets.only(right: 8),
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: isActive ? context.color.primary : context.color.secondary,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Center(
        child: icon != null
            ? Icon(
                icon,
                color: isActive
                    ? context.color.background
                    : context.color.primaryText,
                size: 24,
              )
            : Text(
                label ?? '',
                textAlign: TextAlign.center,
                style: context.text.labelLarge.copyWith(
                  fontWeight: FontWeight.w500,
                  color: isActive
                      ? context.color.background
                      : context.color.primaryText,
                ),
              ),
      ),
    ),
  );
}
