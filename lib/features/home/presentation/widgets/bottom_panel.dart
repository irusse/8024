import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:neighbours/core/components/custom_gap.dart';
import 'package:neighbours/core/cubits/user/user_cubit.dart';
import 'package:neighbours/core/extensions/context_ext.dart';
import 'package:neighbours/core/router/app_routes.dart';
import 'package:neighbours/core/themes/theme.dart';
import 'package:neighbours/features/home/domain/enums/map_display_mode.dart';
import 'package:neighbours/features/property/presentation/cubits/properties/properties_cubit.dart';

import '../cubits/home/home_cubit.dart';

class BottomPanel extends StatefulWidget {
  final Function(double, double) navigateToProperty;

  const BottomPanel({super.key, required this.navigateToProperty});

  @override
  State<BottomPanel> createState() => _BottomPanelState();
}

class _BottomPanelState extends State<BottomPanel> {
  DateTime? _lastHomeClickTime;

  void _onHomeClick(BuildContext context) {
    final homeCubit = context.read<HomeCubit>();
    final userId = context.read<UserCubit>().state.user.id;
    final property = context.read<PropertiesCubit>().getMyProperty(userId);

    if (property == null) {
      homeCubit
        ..setIdle()
        ..goToAddPropertyStep();
      return;
    }

    final now = DateTime.now();
    final isSecondClick = _lastHomeClickTime != null &&
        now.difference(_lastHomeClickTime!).inSeconds < 3;

    if (isSecondClick) {
      // Второй клик - открываем карточку

      _lastHomeClickTime = null; // Сбрасываем для следующего цикла
      context.push(AppRouteBuilder.propertyDetails(property.id));
    } else {
      // Первый клик - летим к объекту
      _lastHomeClickTime = now;
      homeCubit.showOnlyProperty();

      widget.navigateToProperty(property.latitude, property.longitude);
    }
  }

  void _onAllClick(BuildContext context) {
    _lastHomeClickTime = null; // Сбрасываем при переключении режима
    context.read<HomeCubit>().showAllLayers();
  }

  void _onPlanBClick(BuildContext context) {
    _lastHomeClickTime = null; // Сбрасываем при переключении режима
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
                  activeColor: context.color.primary,
                  icon: Icons.home_filled,
                  isActive: displayMode == MapDisplayMode.propertyOnly,
                  onTap: () => _onHomeClick(context),
                ),
                _buildNavButton(
                  context,
                  label: 'Все',
                  activeColor: context.color.primary,
                  isActive: displayMode == MapDisplayMode.all,
                  onTap: () => _onAllClick(context),
                ),
                _buildNavButton(
                  context,
                  label: 'План Б',
                  activeColor: CommonModeColors.purple,
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

Widget _buildNavButton(BuildContext context,
    {required VoidCallback onTap,
    required Color activeColor,
    IconData? icon,
    String? label,
    bool isActive = false}) {
  return GestureDetector(
    onTap: onTap,
    child: Container(
      margin: const EdgeInsets.only(right: 8),
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: isActive ? activeColor : context.color.secondary,
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
                  color: isActive ? Colors.white : context.color.primaryText,
                ),
              ),
      ),
    ),
  );
}
