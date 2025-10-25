import 'package:flutter/material.dart';
import 'package:neighbours/core/components/custom_gap.dart';
import 'package:neighbours/core/extensions/context_ext.dart';
import 'package:neighbours/features/chat/presentation/widgets/event_chat_widget.dart';

class ChatTab extends StatelessWidget {
  final int eventId;
  final bool isChatAvailable;

  const ChatTab(
      {super.key, required this.eventId, required this.isChatAvailable});

  @override
  Widget build(BuildContext context) {
    return isChatAvailable
        ? EventChatWidget(eventId: eventId)
        : Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.chat_bubble_outline,
                  size: 64, color: context.color.secondaryText),
              const VerticalGap(16),
              Text(
                'Присоединяйтесь к мероприятию\nи начинайте общение в чате',
                textAlign: TextAlign.center,
                style: context.text.bodyLarge
                    .copyWith(color: context.color.secondaryText),
              ),
            ],
          );
  }
}
