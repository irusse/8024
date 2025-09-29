import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:neighbours/core/components/custom_gap.dart';
import 'package:neighbours/core/components/custom_svg.dart';
import 'package:neighbours/core/components/shaped_cached_image.dart';
import 'package:neighbours/core/constants/ui_constants.dart';
import 'package:neighbours/core/extensions/context_ext.dart';
import 'package:neighbours/core/router/app_routes.dart';
import 'package:neighbours/features/chat/presentation/cubits/event_chat/event_chat_cubit.dart';
import 'package:neighbours/features/chat/presentation/widgets/unread_count.dart';
import 'package:neighbours/features/event/domain/entities/event/event_entity.dart';

class EventChatListItem extends StatelessWidget {
  final EventEntity entity;

  const EventChatListItem({super.key, required this.entity});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () =>
          context.push(AppRouteBuilder.chatPage(entity.id, entity.title)),
      child: Container(
        color: Colors.transparent,
        height: 56,
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.symmetric(
            horizontal: UIConstants.defaultHorizontalPadding),
        child: Row(
          children: [
            Expanded(
              child: Row(
                children: [
                  _chatPicture(context, entity),
                  const HorizontalGap(8),
                  Expanded(
                      child: Text(
                    entity.title,
                    style: context.text.bodyLarge
                        .copyWith(fontWeight: FontWeight.w500),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ))
                ],
              ),
            ),
            const HorizontalGap(16),
            BlocBuilder<EventChatCubit, EventChatState>(
              builder: (context, state) {
                final unreadCount = context
                    .read<EventChatCubit>()
                    .getUnreadCountForEvent(entity.id);
                return UnreadCount(count: unreadCount);
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _chatPicture(BuildContext context, EventEntity event) {
    if (event.image != null && event.image!.isNotEmpty) {
      return ShapedCachedImage(
        url: entity.image,
        radius: 24,
      );
    }
    return CircleAvatar(
        radius: 24,
        backgroundColor: event.category.color,
        child: CustomSvg(
          asset: event.category.icon,
          color: Colors.white,
          width: 24,
          height: 24,
          isNetwork: true,
        ));
  }
}
