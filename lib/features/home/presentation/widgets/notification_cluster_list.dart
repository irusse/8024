import 'package:flutter/material.dart';
import 'package:neighbours/core/domain/entities/event/event_entity.dart';
import 'package:neighbours/core/extensions/context_ext.dart';
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
      height: 220,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: notifications.length,
        padding: const EdgeInsets.symmetric(
          horizontal: 8,
        ),
        itemBuilder: (context, index) {
          final notification = notifications[index];
          return Padding(
            padding: const EdgeInsets.only(right: 12),
            child: SizedBox(
                width: MediaQuery.of(context).size.width - 40,
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    color: context.color.background,
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: NotificationInfoDialog(
                      eventId: notification.id,
                      userId: userId,
                      onNotRelevantClick: onNotRelevantClick),
                )),
          );
        },
      ),
    );
  }
}
