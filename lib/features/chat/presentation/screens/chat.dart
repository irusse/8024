import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:neighbours/core/components/chat_widget.dart';
import 'package:neighbours/core/components/default_app_bar.dart';
import 'package:neighbours/core/cubits/chat/chat_cubit.dart';
import 'package:neighbours/core/extensions/context_ext.dart';
import 'package:neighbours/core/state/api_state.dart';
import 'package:neighbours/features/chat/presentation/widgets/message_input.dart';
import 'package:neighbours/features/chat/presentation/widgets/message_list.dart';

class Chat extends StatelessWidget {
  final int eventId;

  const Chat({super.key, required this.eventId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const DefaultAppBar(showBackButton: true, title: 'Чат'),
      body: ChatWidget(
        eventId: eventId,
      ),
    );
  }
}
