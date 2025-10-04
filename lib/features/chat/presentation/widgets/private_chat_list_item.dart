import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:neighbours/core/components/custom_gap.dart';
import 'package:neighbours/core/components/shaped_cached_image.dart';
import 'package:neighbours/core/constants/ui_constants.dart';
import 'package:neighbours/core/extensions/context_ext.dart';
import 'package:neighbours/core/extensions/full_name_ext.dart';
import 'package:neighbours/core/router/app_routes.dart';
import 'package:neighbours/features/chat/presentation/cubits/private_message/private_message_cubit.dart';
import 'package:neighbours/features/chat/presentation/widgets/unread_count.dart';
import 'package:neighbours/features/other_profile/domain/entities/other_user/other_user_entity.dart';

class PrivateChatListItem extends StatelessWidget {
  final int conversationId;
  final OtherUserEntity interlocutor;
  final String? lastMessage;
  final DateTime? lastMessageTime;

  const PrivateChatListItem({
    super.key,
    required this.conversationId,
    required this.interlocutor,
    this.lastMessage,
    this.lastMessageTime,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => context.push(
        AppRouteBuilder.privateChatPage(interlocutor.id),
        extra: {
          'conversationId': conversationId,
          'receiverId': interlocutor.id, // Для новых бесед
          'interlocutorName': interlocutor.firstName,
          'interlocutorAvatarUrl': interlocutor.avatar,
        },
      ),
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: UIConstants.defaultHorizontalPadding,
          vertical: 12,
        ),
        child: Row(
          children: [
            _userAvatar(context),
            const HorizontalGap(16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    interlocutor.firstName,
                    style: context.text.bodyLarge.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (lastMessage != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      lastMessage!,
                      style: context.text.bodySmall?.copyWith(
                        color: context.color.secondaryText,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ],
              ),
            ),
            const HorizontalGap(8),
            BlocBuilder<PrivateMessageCubit, PrivateMessageState>(
              builder: (context, state) {
                final unreadCount = context
                    .read<PrivateMessageCubit>()
                    .getUnreadCountForConversation(conversationId);

                return UnreadCount(count: unreadCount);
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _userAvatar(BuildContext context) {
    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: context.color.primary.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: ClipOval(
        child: interlocutor.avatar != null && interlocutor.avatar!.isNotEmpty
            ? ShapedCachedImage(
                url: interlocutor.avatar!,
                radius: 24,
              )
            : Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      context.color.primary,
                      context.color.primary.withOpacity(0.7),
                    ],
                  ),
                ),
                child: Center(
                  child: Text(
                    interlocutor.fullName,
                    style: context.text.titleSmall.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
      ),
    );
  }
}
