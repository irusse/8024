import 'package:flutter/material.dart';
import 'package:neighbours/features/chat/presentation/widgets/community_chat_widget.dart';
import 'package:neighbours/core/components/default_app_bar.dart';

class CommunityChatPage extends StatelessWidget {
  final int communityId;
  final String title;

  const CommunityChatPage({
    super.key, 
    required this.communityId, 
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: DefaultAppBar(showBackButton: true, title: title),
      body: CommunityChatWidget(communityId: communityId),
    );
  }
}
