import 'package:flutter/material.dart';
import 'package:neighbours/features/chat/presentation/widgets/chat_widget.dart';
import 'package:neighbours/core/components/default_app_bar.dart';

class Chat extends StatelessWidget {
  final int eventId;
  final String eventTitle;

  const Chat({super.key, required this.eventId, required this.eventTitle});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: DefaultAppBar(showBackButton: true, title: eventTitle),
      body: ChatWidget(
        eventId: eventId,
      ),
    );
  }
}
