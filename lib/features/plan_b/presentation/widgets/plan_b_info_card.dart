import 'package:flutter/material.dart';
import 'package:neighbours/core/components/custom_gap.dart';
import 'package:neighbours/core/constants/ui_constants.dart';
import 'package:neighbours/core/extensions/context_ext.dart';

class PlanBInfoCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final Widget child;

  const PlanBInfoCard({
    super.key,
    required this.icon,
    required this.title,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: UIConstants.defaultHorizontalPadding,
      ),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: context.color.secondary,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: context.color.tertiary.withValues(alpha: .08),
              blurRadius: 20,
              offset: const Offset(0, 4),
            ),
          ],
          border: Border.all(
            color: context.color.tertiary.withValues(alpha: .1),
            width: 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  icon,
                  color: context.color.primary,
                  size: 20,
                ),
                const HorizontalGap(8),
                Text(
                  title,
                  style: context.text.titleSmall.copyWith(
                    fontWeight: FontWeight.w600,
                    color: context.color.primaryText,
                  ),
                ),
              ],
            ),
            const VerticalGap(20),
            child,
          ],
        ),
      ),
    );
  }
}
