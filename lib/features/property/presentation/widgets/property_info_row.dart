import 'package:flutter/material.dart';
import 'package:neighbours/core/extensions/context_ext.dart';

import '../../../../core/components/custom_gap.dart';

class PropertyInfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const PropertyInfoRow(
      {super.key,
      required this.icon,
      required this.label,
      required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: context.color.primary.withValues(alpha: .1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            size: 16,
            color: context.color.primary,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: context.text.bodySmall.copyWith(
                  color: context.color.secondaryText,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const HorizontalGap(2),
              Text(
                value,
                style: context.text.bodyMedium.copyWith(
                  color: context.color.primaryText,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
