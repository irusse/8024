import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:neighbours/core/components/custom_gap.dart';
import 'package:neighbours/core/components/default_app_bar.dart';
import 'package:neighbours/core/components/default_loading_overlay.dart';
import 'package:neighbours/core/components/default_tab_bar.dart';
import 'package:neighbours/core/cubits/user/user_cubit.dart';
import 'package:neighbours/core/state/api_state.dart';
import 'package:neighbours/features/chat/presentation/widgets/community_chat_list_item.dart';
import 'package:neighbours/features/chat/presentation/widgets/private_chat_list_item.dart';
import 'package:neighbours/features/chat/presentation/cubits/private_chat/private_chat_cubit.dart';
import 'package:neighbours/features/community/domain/entities/community/community_entity.dart';
import 'package:neighbours/features/community/presentation/widgets/error_with_try_btn.dart';
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
    context.read<PrivateChatCubit>().fetchPrivateConversations();
  }

  @override
  Widget build(BuildContext context) {
    final userId = context.read<UserCubit>().state.user.id;
    final allUserEvents = context.select<EventsCubit, List<EventEntity>>(
        (cubit) => cubit.allUserFullEvents(userId));
    final allUserNotifications = context.select<EventsCubit, List<EventEntity>>(
        (cubit) => cubit.allUserNotifications(userId));
    final communities = context.select<UserCubit, List<CommunityEntity>>(
        (cubit) => cubit.state.user.communities);
    final _tabs = ["Сообщества", "Мероприятия", "Оповещения", "Личные"];
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
                  _buildPrivateChatsList(context),
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
        // Показываем индикатор загрузки
        if (state.fetchConversationsState.isLoading) {
          return DefaultLoadingOverlay();
        }

        // Показываем ошибку
        if (state.fetchConversationsState.isFailure) {
          return ErrorWithTryBtn(
              error: state.fetchConversationsState.error!,
              onErrorClick: () =>
                  context.read<PrivateChatCubit>().fetchPrivateConversations());
        }

        // Получаем список бесед из состояния
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
}
