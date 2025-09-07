import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:neighbours/core/components/custom_gap.dart';
import 'package:neighbours/core/constants/ui_constants.dart';
import 'package:neighbours/core/di/injection.dart';
import 'package:neighbours/core/extensions/context_ext.dart';
import 'package:neighbours/core/services/notification_service.dart';
import 'package:neighbours/features/notification/domain/entities/notification/notification_entity.dart';
import 'package:neighbours/features/notification/presentation/cubits/notification_cubit.dart';

class NotificationItem extends StatelessWidget {
  final NotificationEntity entity;

  const NotificationItem({super.key, required this.entity});

  String _formatDateTime(DateTime dateTime) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final target = DateTime(dateTime.year, dateTime.month, dateTime.day);

    // если сегодня
    if (target == today) {
      return 'Сегодня, ${DateFormat('HH:mm').format(dateTime)}';
    }

    // если вчера
    if (target == today.subtract(const Duration(days: 1))) {
      return 'Вчера, ${DateFormat('HH:mm').format(dateTime)}';
    }
    // иначе — обычная дата
    return DateFormat('dd.MM HH:mm').format(dateTime);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        if (!entity.isRead) {
          context.read<NotificationCubit>().markAsRead(entity.id);
        }
        final newPayload = {...entity.payload, "type": entity.type};

        getIt<NotificationService>().handleNotificationTap(newPayload);

      },
      child: Container(
        decoration: BoxDecoration(
          color: entity.isRead
              ? Colors.transparent
              : context.color.primary.withValues(alpha: 0.1),
          border: Border(
            bottom: BorderSide(
              color: context.color.tertiary.withValues(alpha: 0.1),
              width: 1.0,
            ),
          ),
        ),
        padding: const EdgeInsets.symmetric(
            horizontal: UIConstants.defaultHorizontalPadding, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Flexible(
                    child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    if (!entity.isRead)
                      Container(
                        margin: const EdgeInsets.only(right: 6),
                        width: 6,
                        height: 6,
                        decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: context.color.basicRed),
                      ),
                    Expanded(
                      child: Text(
                        entity.title,
                        style: context.text.bodyMedium
                            .copyWith(fontWeight: FontWeight.w500),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                )),
                const HorizontalGap(8),
                Text(
                  _formatDateTime(entity.createdAt),
                  style: context.text.labelLarge
                      .copyWith(color: context.color.secondaryText),
                ),
              ],
            ),
            const VerticalGap(8),
            Container(
              margin: EdgeInsets.only(left: entity.isRead ? 0 : 12),
              child: Text(
                entity.message,
                style: context.text.bodyMedium
                    .copyWith(color: context.color.secondaryText),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const VerticalGap(8),
          ],
        ),
      ),
    );
  }
}
