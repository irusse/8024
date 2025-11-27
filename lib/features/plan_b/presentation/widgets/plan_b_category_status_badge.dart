import 'package:flutter/material.dart';
import 'package:neighbours/core/components/custom_gap.dart';
import 'package:neighbours/core/constants/ui_constants.dart';
import 'package:neighbours/core/extensions/context_ext.dart';

class PlanBCategoryStatusBadge extends StatelessWidget {
  final String category;
  final String status;

  const PlanBCategoryStatusBadge({
    super.key,
    required this.category,
    required this.status,
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
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Категория',
                    style: context.text.bodySmall?.copyWith(
                      color: context.color.secondaryText,
                    ),
                  ),
                  const VerticalGap(8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFF9800).withValues(alpha: .15),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: const Color(0xFFFF9800),
                        width: 1,
                      ),
                    ),
                    child: Text(
                      category,
                      style: context.text.bodyMedium?.copyWith(
                        color: const Color(0xFFFF9800),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const HorizontalGap(16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Статус',
                    style: context.text.bodySmall?.copyWith(
                      color: context.color.secondaryText,
                    ),
                  ),
                  const VerticalGap(8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: status == 'ACTIVE'
                          ? Colors.green.withValues(alpha: .15)
                          : context.color.tertiary.withValues(alpha: .15),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: status == 'ACTIVE'
                            ? Colors.green
                            : context.color.tertiary,
                        width: 1,
                      ),
                    ),
                    child: Text(
                      status == 'ACTIVE' ? 'Активен' : status,
                      style: context.text.bodyMedium?.copyWith(
                        color: status == 'ACTIVE'
                            ? Colors.green
                            : context.color.secondaryText,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
