import 'package:flutter/material.dart';
import 'package:neighbours/core/components/custom_svg.dart';
import 'package:neighbours/core/constants/assets.dart';
import 'package:neighbours/core/extensions/context_ext.dart';

class ViewSwitcher extends StatelessWidget {
  final ValueNotifier<int> notifier;

  const ViewSwitcher({
    super.key,
    required this.notifier,
  });

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<int>(
      valueListenable: notifier,
      builder: (context, selectedIndex, child) {
        return Container(
          padding: const EdgeInsets.symmetric(vertical: 4),
          width: 48,
          height: 80,
          decoration: BoxDecoration(
            color: context.color.secondary,
            borderRadius: BorderRadius.circular(90),
          ),
          child: Column(
            children: [
              Expanded(
                child: _button(
                  context,
                  isActive: selectedIndex == 0,
                  iconPath: Assets.icons.location,
                  onTap: () => notifier.value = 0,
                ),
              ),
              Expanded(
                child: _button(
                  context,
                  isActive: selectedIndex == 1,
                  iconPath: Assets.icons.rowVertical,
                  onTap: () => notifier.value = 1,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _button(
    BuildContext context, {
    required bool isActive,
    required String iconPath,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        alignment: Alignment.center,
        decoration: BoxDecoration(
            color: isActive ? context.color.primary : Colors.transparent,
            shape: BoxShape.circle),
        child: CustomSvg(
          asset: iconPath,
          width: 24,
          height: 24,
          color: isActive ? Colors.white : context.color.secondaryText,
        ),
      ),
    );
  }
}
