import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:neighbours/core/extensions/context_ext.dart';
import 'package:neighbours/core/router/app_routes.dart';
import 'package:neighbours/features/community/domain/entities/community/community_entity.dart';

class CommunityChatListItem extends StatelessWidget {
  final CommunityEntity entity;

  const CommunityChatListItem({super.key, required this.entity});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () =>
          context.push(AppRouteBuilder.chatPage(entity.id, entity.name)),
      child: Row(
        children: [
          Text(
            entity.name,
            style: context.text.bodyMedium,
          )
        ],
      ),
    );
  }
}
