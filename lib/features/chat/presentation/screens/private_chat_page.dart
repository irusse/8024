import 'package:flutter/material.dart';
import 'package:neighbours/core/components/default_circle_avatar.dart';
import 'package:neighbours/features/chat/presentation/widgets/private_chat_widget.dart';
import 'package:neighbours/core/components/default_app_bar.dart';
import 'package:neighbours/core/components/custom_gap.dart';
import 'package:neighbours/core/extensions/context_ext.dart';

class PrivateChatPage extends StatelessWidget {
  final int? conversationId;
  final int? receiverId;
  final String interlocutorName;
  final String? interlocutorAvatarUrl;

  const PrivateChatPage({
    super.key,
    this.conversationId,
    this.receiverId,
    required this.interlocutorName,
    this.interlocutorAvatarUrl,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: DefaultAppBar(
        showBackButton: true,
        titleWidget: _buildAppBarContent(context),
        height: 80,
      ),
      body: PrivateChatWidget(
        conversationId: conversationId,
        receiverId: receiverId,
      ),
    );
  }

  Widget _buildAppBarContent(BuildContext context) {
    return Expanded(
        child: Row(
      children: [
        DefaultCircleAvatar(
          name: interlocutorName,
          id: receiverId,
          radius: 24,
          textStyle: context.text.bodyLarge,
          url: interlocutorAvatarUrl,
        ),
        // Аватар собеседника

        const HorizontalGap(12),
        // Имя собеседника
        Flexible(
          child: Text(
            interlocutorName +
                interlocutorName +
                interlocutorName +
                interlocutorName,
            style: context.text.titleSmall,
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
          ),
        )
      ],
    ));
  }
}

