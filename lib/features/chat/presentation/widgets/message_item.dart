import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:neighbours/core/components/custom_gap.dart';
import 'package:neighbours/core/extensions/context_ext.dart';
import 'package:neighbours/features/chat/domain/entities/message/message_entity.dart';

import '../../../../core/components/default_circle_avatar.dart';

class MessageItem extends StatelessWidget {
  final int userId;
  final MessageEntity message;

  const MessageItem({super.key, required this.message, required this.userId});

  @override
  Widget build(BuildContext context) {
    final isMyMessage = message.user.id == userId;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment:
            isMyMessage ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!isMyMessage) ...[
            DefaultCircleAvatar(
              id: message.userId,
              name: message.user.firstName,
              url: message.user.avatar,
              textStyle: context.text.labelLarge.copyWith(
                fontWeight: FontWeight.w500,
              ),
              radius: 16,
            ),
            const HorizontalGap(8),
          ],
          Flexible(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: isMyMessage
                        ? context.color.primary
                        : context.color.secondary,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        message.text,
                        style: context.text.bodyMedium
                            .copyWith(color: isMyMessage ? Colors.white : null),
                      ),
                      const VerticalGap(4),
                      Text(
                        DateFormat("HH:mm").format(message.createdAt),
                        style: TextStyle(
                          fontSize: 10,
                          color: isMyMessage
                              ? Colors.white.withValues(alpha: 0.7)
                              : Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          if (isMyMessage) ...[
            const SizedBox(width: 8),
            DefaultCircleAvatar(
                id: message.userId,
                name: "Я",
                url: message.user.avatar,
                radius: 16,
                textStyle: context.text.labelLarge
                    .copyWith(fontWeight: FontWeight.w500))
          ],
        ],
      ),
    );
  }
}
