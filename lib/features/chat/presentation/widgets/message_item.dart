import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:neighbours/core/components/custom_gap.dart';
import 'package:neighbours/core/extensions/color_ext.dart';
import 'package:neighbours/core/extensions/context_ext.dart';
import 'package:neighbours/core/router/app_routes.dart';
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
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!isMyMessage) ...[
            GestureDetector(
              onTap: () =>
                  context.push(AppRouteBuilder.otherProfile(message.userId)),
              child: DefaultCircleAvatar(
                id: message.userId,
                name: message.user.firstName,
                url: message.user.avatar,
                textStyle: context.text.labelLarge.copyWith(
                  fontWeight: FontWeight.w500,
                ),
                radius: 18,
              ),
            ),
            const HorizontalGap(8),
          ],
          Flexible(
            child: Padding(
              padding: EdgeInsets.only(
                left: isMyMessage ? 40 : 0,
                right: isMyMessage ? 0 : 40,
              ),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: isMyMessage
                      ? context.color.primary
                      : context.color.secondary,
                  borderRadius: BorderRadius.only(
                    topLeft: const Radius.circular(16),
                    topRight: const Radius.circular(16),
                    bottomLeft:
                        isMyMessage ? const Radius.circular(16) : Radius.zero,
                    bottomRight:
                        isMyMessage ? Radius.zero : const Radius.circular(16),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (!isMyMessage) ...[
                      Text(
                        message.user.fullName,
                        style: context.text.bodySmall.copyWith(
                          fontWeight: FontWeight.w600,
                          color: ColorExtension.byIndex(message.userId),
                        ),
                      ),
                    ],
                    Text(
                      message.text,
                      style: context.text.bodyMedium.copyWith(
                        color: isMyMessage ? Colors.white : null,
                      ),
                    ),
                    const VerticalGap(4),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          DateFormat("HH:mm").format(message.createdAt),
                          textAlign: TextAlign.start,
                          style: TextStyle(
                            fontSize: 10,
                            color: isMyMessage
                                ? Colors.white.withValues(alpha: 0.7)
                                : Colors.grey,
                          ),
                        ),
                        if (isMyMessage) ...[
                          const HorizontalGap(4),
                          _buildMessageStatusIcon(context, message),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageStatusIcon(BuildContext context, MessageEntity message) {
    // Проверяем, есть ли пользователи в массиве seenUsers
    final hasSeenUsers =
        message.seenUsers != null && message.seenUsers!.isNotEmpty;

    // Если seenUsers == null, проверяем isRead
    final isMessageRead =
        hasSeenUsers || (message.seenUsers == null && message.isRead == true);

    return Icon(isMessageRead ? Icons.done_all : Icons.done,
        color: Colors.white, size: 12);
  }
}
