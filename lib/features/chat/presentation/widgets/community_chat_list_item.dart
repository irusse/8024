import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:neighbours/core/components/custom_gap.dart';
import 'package:neighbours/core/constants/ui_constants.dart';
import 'package:neighbours/core/extensions/context_ext.dart';
import 'package:neighbours/core/router/app_routes.dart';
import 'package:neighbours/features/chat/presentation/cubits/community_chat/community_chat_cubit.dart';
import 'package:neighbours/features/chat/presentation/widgets/unread_count.dart';
import 'package:neighbours/features/community/domain/entities/community/community_entity.dart';

class CommunityChatListItem extends StatelessWidget {
  final CommunityEntity entity;

  const CommunityChatListItem({super.key, required this.entity});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () =>
          context.push(AppRouteBuilder.communityChatPage(entity.id, entity.name)),
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: UIConstants.defaultHorizontalPadding,
          vertical: 12,
        ),
        child: Row(
          children: [
            _communityAvatar(context),
            const HorizontalGap(16),
            Expanded(
                child: Text(
              entity.name,
              style: context.text.bodyLarge.copyWith(
                fontWeight: FontWeight.w500,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            )),
            const HorizontalGap(8),
            BlocBuilder<CommunityChatCubit, CommunityChatState>(
              builder: (context, state) {
                final unreadCount = context
                    .read<CommunityChatCubit>()
                    .getUnreadCountForCommunity(entity.id);

                return UnreadCount(count: unreadCount);
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _communityAvatar(BuildContext context) {
    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            context.color.primary,
            context.color.primary.withValues(alpha: 0.7),
          ],
        ),
        shape: BoxShape.circle,
      ),
      child: Center(
        child: Text(
          entity.name.isNotEmpty ? entity.name[0].toUpperCase() : 'C',
          style: context.text.titleSmall.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
