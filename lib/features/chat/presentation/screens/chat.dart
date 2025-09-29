import 'package:flutter/material.dart';
import 'package:neighbours/features/chat/presentation/widgets/chat_widget.dart';
import 'package:neighbours/core/components/default_app_bar.dart';

class Chat extends StatelessWidget {
  final int id;
  final String title;

  const Chat({super.key, required this.id, required this.title});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: DefaultAppBar(showBackButton: true, title: title),
      body: ChatWidget(
        eventId: id,
      ),
    );
  }
}
