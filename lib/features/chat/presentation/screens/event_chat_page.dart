import 'package:flutter/material.dart';
import 'package:neighbours/features/chat/presentation/widgets/event_chat_widget.dart';
import 'package:neighbours/core/components/default_app_bar.dart';

class EventChatPage extends StatelessWidget {
  final int eventId;
  final String title;

  const EventChatPage({
    super.key, 
    required this.eventId, 
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: DefaultAppBar(showBackButton: true, title: title),
      body: EventChatWidget(eventId: eventId),
    );
  }
}
