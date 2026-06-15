import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:neighbours/core/components/custom_gap.dart';
import 'package:neighbours/core/components/default_circle_avatar.dart';
import 'package:neighbours/core/constants/ui_constants.dart';
import 'package:neighbours/core/extensions/context_ext.dart';
import 'package:neighbours/core/router/app_routes.dart';
import 'package:neighbours/features/chat/presentation/cubits/private_chat/private_chat_cubit.dart';
import 'package:neighbours/features/chat/presentation/widgets/unread_count.dart';
import 'package:neighbours/features/chat/domain/entities/private_chat_list/private_chat_list_entity.dart';

class PrivateChatListItem extends StatelessWidget {
  final PrivateChatListEntity conversation;

  const PrivateChatListItem({
    super.key,
    required this.conversation,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PrivateChatCubit, PrivateChatState>(
      builder: (context, state) {
        // Ищем актуальную беседу в состоянии кубита
        final updatedConversation = state.conversations.firstWhere(
          (conv) => conv.user.id == conversation.user.id,
          orElse: () => conversation, // Если не найдена, используем переданную
        );

        return GestureDetector(
          onTap: () => context.push(
            AppRouteBuilder.privateChatPage(conversation.user.id),
            extra: {
              'interlocutorName': conversation.user.firstName,
              'interlocutorAvatarUrl': conversation.user.avatar,
            },
          ),
          child: Container(
            padding: const EdgeInsets.symmetric(
              horizontal: UIConstants.defaultHorizontalPadding,
              vertical: 12,
            ),
            decoration: BoxDecoration(color: Colors.transparent),
            child: Row(
              children: [
                DefaultCircleAvatar(
                  name: conversation.user.firstName,
                  radius: 24,
                  textStyle: context.text.bodyMedium,
                  id: conversation.user.id,
                  url: conversation.user.avatar,
                ),
                const HorizontalGap(16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        conversation.user.firstName,
                        style: context.text.bodyLarge.copyWith(
                          fontWeight: FontWeight.w500,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const VerticalGap(4),
                      Text(
                        updatedConversation.lastMessage.text,
                        style: context.text.bodySmall.copyWith(
                          color: context.color.secondaryText,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                const HorizontalGap(8),
                UnreadCount(count: updatedConversation.unreadCount),
              ],
            ),
          ),
        );
      },
    );
  }
}
