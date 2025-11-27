import 'package:flutter/material.dart';
import 'package:neighbours/core/extensions/context_ext.dart';

class PlanBTextCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String content;

  const PlanBTextCard({
    super.key,
    required this.icon,
    required this.title,
    required this.content,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              icon,
              color: context.color.primary,
              size: 20,
            ),
            const SizedBox(width: 8),
            Text(
              title,
              style: context.text.titleSmall.copyWith(
                fontWeight: FontWeight.w600,
                color: context.color.primaryText,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Text(
          content,
          style: context.text.bodyMedium.copyWith(
            color: context.color.primaryText,
            height: 1.5,
          ),
        ),
      ],
    );
  }
}
