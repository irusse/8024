import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:neighbours/core/extensions/context_ext.dart';
import 'package:neighbours/features/event/domain/entities/event/event_entity.dart';

import '../../../../core/components/custom_gap.dart';

class CompletedEventCard extends StatelessWidget {
  final EventEntity event;

  const CompletedEventCard({super.key, required this.event});

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('dd.MM.yy');
    
    return Container(
      margin: const EdgeInsets.only(bottom: 6),
      decoration: BoxDecoration(
        color: context.color.secondary.withOpacity(0.5),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(
          color: context.color.secondaryText.withOpacity(0.2),
          width: 0.5,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Row(
          children: [
            // Иконка завершенного события
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: context.color.secondaryText.withOpacity(0.1),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(
                Icons.check_circle_outline,
                size: 18,
                color: context.color.secondaryText.withOpacity(0.6),
              ),
            ),
            const HorizontalGap(12),
            
            // Основная информация
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    event.title,
                    style: context.text.bodyMedium.copyWith(
                      fontWeight: FontWeight.w500,
                      color: context.color.secondaryText.withOpacity(0.8),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const VerticalGap(2),
                  Row(
                    children: [
                      Text(
                        dateFormat.format(event.createdAt),
                        style: context.text.bodySmall.copyWith(
                          color: context.color.secondaryText.withOpacity(0.5),
                        ),
                      ),
                      const HorizontalGap(8),
                      Text(
                        '•',
                        style: context.text.bodySmall.copyWith(
                          color: context.color.secondaryText.withOpacity(0.3),
                        ),
                      ),
                      const HorizontalGap(8),
                      Text(
                        '${event.participants.length} участников',
                        style: context.text.bodySmall.copyWith(
                          color: context.color.secondaryText.withOpacity(0.5),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            
            // Дата завершения (если есть eventDateTime)
            if (event.eventDateTime != null) ...[
              const HorizontalGap(8),
              Text(
                dateFormat.format(event.eventDateTime!),
                style: context.text.bodySmall.copyWith(
                  color: context.color.secondaryText.withOpacity(0.4),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
