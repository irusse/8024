import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:neighbours/core/components/custom_gap.dart';
import 'package:neighbours/core/components/default_app_bar.dart';
import 'package:neighbours/core/components/default_loading_overlay.dart';
import 'package:neighbours/core/components/default_tab_bar.dart';
import 'package:neighbours/core/cubits/user/user_cubit.dart';
import 'package:neighbours/core/extensions/context_ext.dart';
import 'package:neighbours/core/state/api_state.dart';
import 'package:neighbours/features/chat/presentation/widgets/community_chat_list_item.dart';
import 'package:neighbours/features/chat/presentation/widgets/private_chat_list_item.dart';
import 'package:neighbours/features/chat/presentation/cubits/private_chat/private_chat_cubit.dart';
import 'package:neighbours/features/community/domain/entities/community/community_entity.dart';
import 'package:neighbours/core/components/error_with_try_btn.dart';
import 'package:neighbours/features/event/domain/entities/event/event_entity.dart';
import 'package:neighbours/features/event/presentation/cubits/events/events_cubit.dart';
import '../widgets/event_chat_list_item.dart';

class ChatList extends StatefulWidget {
  const ChatList({super.key});

  @override
  State<ChatList> createState() => _ChatListState();
}

class _ChatListState extends State<ChatList> {
  @override
  void initState() {
    super.initState();
    // Загружаем список приватных бесед при инициализации
  }

  @override
  Widget build(BuildContext context) {
    final userId = context.read<UserCubit>().state.user.id;
    final allUserEvents = context.select<EventsCubit, List<EventEntity>>(
        (cubit) => cubit
            .allUserFullEvents(userId)
            .where((event) => !event.isCompleted)
            .toList());
    final allUserNotifications = context.select<EventsCubit, List<EventEntity>>(
        (cubit) => cubit
            .allUserNotifications(userId)
            .where((event) => !event.isCompleted)
            .toList());
    final allUserCompletedEvents =
        context.select<EventsCubit, List<EventEntity>>((cubit) => cubit
            .allUserFullEvents(userId)
            .where((event) => event.isCompleted)
            .toList());
    final allUserCompletedNotifications =
        context.select<EventsCubit, List<EventEntity>>((cubit) => cubit
            .allUserNotifications(userId)
            .where((event) => event.isCompleted)
            .toList());
    final communities = context.select<UserCubit, List<CommunityEntity>>(
        (cubit) => cubit.state.user.communities);
    final _tabs = [
      "Личные",
      "Сообщества",
      "Мероприятия",
      "Оповещения",
      "Завершенные",
    ];
    return Scaffold(
      appBar: const DefaultAppBar(
        showBackButton: true,
        title: 'Чаты',
      ),
      body: DefaultTabController(
        length: _tabs.length,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            DefaultTabBar(tabs: _tabs),
            const VerticalGap(16),
            Expanded(
              child: TabBarView(
                children: [
                  _buildPrivateChatsList(context),
                  ListView.builder(
                    itemBuilder: (context, index) =>
                        CommunityChatListItem(entity: communities[index]),
                    itemCount: communities.length,
                  ),
                  ListView.builder(
                    itemBuilder: (context, index) =>
                        EventChatListItem(entity: allUserEvents[index]),
                    itemCount: allUserEvents.length,
                  ),
                  ListView.builder(
                    itemBuilder: (context, index) =>
                        EventChatListItem(entity: allUserNotifications[index]),
                    itemCount: allUserNotifications.length,
                  ),
                  _buildCompletedEventsList(context, allUserCompletedEvents,
                      allUserCompletedNotifications),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPrivateChatsList(BuildContext context) {
    return BlocBuilder<PrivateChatCubit, PrivateChatState>(
      builder: (context, state) {
        if (state.fetchConversationsState.isLoading) {
          return DefaultLoadingOverlay();
        }

        if (state.fetchConversationsState.isFailure) {
          return ErrorWithTryBtn(
              error: state.fetchConversationsState.error!,
              onErrorClick: () =>
                  context.read<PrivateChatCubit>().fetchPrivateConversations());
        }
        final conversations = state.conversations;

        return ListView.builder(
          itemBuilder: (context, index) {
            final conversation = conversations[index];
            return PrivateChatListItem(
              conversation: conversation,
            );
          },
          itemCount: conversations.length,
        );
      },
    );
  }

  Widget _buildCompletedEventsList(
      BuildContext context,
      List<EventEntity> completedEvents,
      List<EventEntity> completedNotifications) {
    final allCompletedEvents = [...completedEvents, ...completedNotifications];

    if (allCompletedEvents.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Нет завершенных событий',
              style: context.text.bodyLarge.copyWith(
                color: context.color.secondaryText,
              ),
            ),
            const VerticalGap(8),
            Text(
              'Завершенные мероприятия и оповещения появятся здесь',
              style: context.text.bodyMedium.copyWith(
                color: context.color.secondaryText,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      itemBuilder: (context, index) =>
          EventChatListItem(entity: allCompletedEvents[index]),
      itemCount: allCompletedEvents.length,
    );
  }
}
