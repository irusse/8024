import 'package:flutter/material.dart';
import 'package:neighbours/core/components/custom_gap.dart';
import 'package:neighbours/core/extensions/context_ext.dart';

class PlanBInfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const PlanBInfoRow({
    super.key,
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          icon,
          size: 20,
          color: context.color.primary.withValues(alpha: .7),
        ),
        const HorizontalGap(12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: context.text.bodySmall.copyWith(
                  color: context.color.secondaryText,
                ),
              ),

              Text(
                value,
                style: context.text.bodyMedium.copyWith(
                  color: context.color.primaryText,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
