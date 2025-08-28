import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:neighbours/core/components/custom_gap.dart';
import 'package:neighbours/core/cubits/properties/properties_cubit.dart';
import 'package:neighbours/core/cubits/user/user_cubit.dart';
import 'package:neighbours/core/extensions/context_ext.dart';
import 'package:neighbours/core/router/app_routes.dart';

import '../cubits/home/home_cubit.dart';

class BottomPanel extends StatelessWidget {
  final Function(double, double) navigateToProperty;

  const BottomPanel({super.key, required this.navigateToProperty});

  void _onHomeClick(BuildContext context, bool onDoubleTap) {
    final homeCubit = context.read<HomeCubit>();
    final userId = context.read<UserCubit>().state.user.id;
    final property = context.read<PropertiesCubit>().getUserProperty(userId);
    if (property == null) {
      homeCubit
        ..setIdle()
        ..goToAddPropertyStep();
    } else {
      if (onDoubleTap) {
        navigateToProperty(property.latitude, property.longitude);
      } else {
        context.push(AppRouteBuilder.propertyDetails(property.id));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
        height: 36,
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              const HorizontalGap(8),
              _buildNavButton(context,
                  icon: Icons.home_filled,
                  onTap: () => _onHomeClick(context, false),
                  onDoubleTap: () => _onHomeClick(context, true)),
              _buildNavButton(context, label: 'Помощь', onTap: () {}),
              _buildNavButton(context, label: 'Ресурсы', onTap: () {}),
              _buildNavButton(context, label: 'Объекты', onTap: () {}),
              _buildNavButton(context, label: 'Соседи', onTap: () {})
            ],
          ),
        ));
  }
}

Widget _buildNavButton(BuildContext context,
    {required VoidCallback onTap,
    VoidCallback? onDoubleTap,
    IconData? icon,
    String? label}) {
  return GestureDetector(
    onTap: onTap,
    onDoubleTap: onDoubleTap,
    child: Container(
      margin: const EdgeInsets.only(right: 8),
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: context.color.secondary,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Center(
        child: icon != null
            ? Icon(icon, color: context.color.primaryText, size: 24)
            : Text(
                label ?? '',
                textAlign: TextAlign.center,
                style: context.text.labelLarge
                    .copyWith(fontWeight: FontWeight.w500),
              ),
      ),
    ),
  );
}
