import 'package:flutter/material.dart';
import 'package:neighbours/core/components/chat_widget.dart';

class ChatTab extends StatelessWidget {
  final int eventId;
  final bool isChatAvailable;

  const ChatTab(
      {super.key, required this.eventId, required this.isChatAvailable});

  @override
  Widget build(BuildContext context) {
    return isChatAvailable
        ? ChatWidget(eventId: eventId)
        : Container(
            child: const Center(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Присоединяйтесь к сообществу и начинайте общение в чате',
                    textAlign: TextAlign.center,
                  )
                ],
              ),
            ),
          );
  }
}
