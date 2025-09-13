import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:neighbours/core/components/icon_text_span.dart';
import 'package:neighbours/core/components/shaped_cached_image.dart';
import 'package:neighbours/core/extensions/context_ext.dart';
import 'package:neighbours/core/router/app_routes.dart';
import 'package:neighbours/features/event/domain/entities/event/event_entity.dart';

import '../../../../core/components/custom_gap.dart';

class EventCard extends StatelessWidget {
  final EventEntity event;

  const EventCard({super.key, required this.event});

  String getConvertedEventDateTime(
      DateFormat dateFormat, DateTime? eventDateTime) {
    return eventDateTime != null
        ? dateFormat.format(eventDateTime)
        : 'Не указано';
  }

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('yy.MM.dd HH:mm');
    return GestureDetector(
      onTap: () => context.push(AppRouteBuilder.eventDetails(event.id)),
      child: Container(
          margin: const EdgeInsets.only(bottom: 8),
          decoration: BoxDecoration(
            color: context.color.secondary,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      dateFormat.format(event.createdAt),
                      style: context.text.labelLarge
                          .copyWith(color: context.color.secondaryText),
                    ),
                    Text(
                      'Участники: ${event.participants.length}',
                      style: context.text.labelLarge
                          .copyWith(color: context.color.secondaryText),
                    )
                  ],
                ),
                const VerticalGap(8),
                Text(
                  event.title,
                  style: context.text.titleSmall
                      .copyWith(fontWeight: FontWeight.w500),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
                if (event.description.isNotEmpty) ...[
                  const VerticalGap(4),
                  AutoSizeText(
                    event.description,
                    style: context.text.bodyLarge,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
                const VerticalGap(8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        IconTextSpan(
                          icon: Icons.access_time,
                          text: getConvertedEventDateTime(
                              dateFormat, event.eventDateTime),
                          iconColor: context.color.secondaryText,
                          textStyle: context.text.bodyMedium.copyWith(
                              color: context.color.primary,
                              fontWeight: FontWeight.w500),
                        ),
                        const VerticalGap(4),
                        IconTextSpan(
                          icon: Icons.list_alt_outlined,
                          text: event.hasVoting ? 'Да' : 'Нет',
                          iconColor: context.color.secondaryText,
                          textStyle: context.text.bodyMedium.copyWith(
                              color: context.color.primary,
                              fontWeight: FontWeight.w500),
                        ),
                      ],
                    ),
                    ShapedCachedImage(
                      radius: 28,
                      url: event.image,
                    )
                  ],
                )
              ],
            ),
          )),
    );
  }
}
