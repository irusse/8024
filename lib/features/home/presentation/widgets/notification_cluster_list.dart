import 'package:flutter/material.dart';
import 'package:neighbours/core/components/custom_gap.dart';
import 'package:neighbours/core/components/drag_handle.dart';
import 'package:neighbours/core/extensions/context_ext.dart';
import 'package:neighbours/features/event/domain/entities/event/event_entity.dart'
    show EventEntity;
import 'package:neighbours/features/home/presentation/widgets/notification_info_dialog.dart';

class NotificationClusterList extends StatelessWidget {
  final List<EventEntity> notifications;
  final ValueChanged<int> onNotRelevantClick;
  final int userId;

  const NotificationClusterList(
      {super.key,
      required this.notifications,
      required this.onNotRelevantClick,
      required this.userId});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 240,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: notifications.length,
        padding: const EdgeInsets.symmetric(
          horizontal: 8,
        ),
        itemBuilder: (context, index) {
          final notification = notifications[index];
          return Container(
            margin: const EdgeInsets.only(right: 12),
            width: MediaQuery.of(context).size.width - 32,
            decoration: BoxDecoration(
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(20),
              ),
              color: context.color.background,
            ),
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const DragHandle(),
                const VerticalGap(16),
                NotificationInfoDialog(
                    eventId: notification.id,
                    userId: userId,
                    onNotRelevantClick: onNotRelevantClick),
              ],
            ),
          );
        },
      ),
    );
  }
}
