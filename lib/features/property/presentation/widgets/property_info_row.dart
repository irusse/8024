import 'package:flutter/material.dart';
import 'package:neighbours/core/components/custom_gap.dart';
import 'package:neighbours/core/extensions/context_ext.dart';

class PropertyInfoRow extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final VoidCallback? onClick;

  const PropertyInfoRow({
    super.key,
    required this.label,
    required this.value,
    required this.icon,
    this.onClick
  });

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
        const HorizontalGap(12),
        Expanded(
          child: GestureDetector(
            onTap: onClick,
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
                const VerticalGap(2),
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
        ),
      ],
    );
  }
}