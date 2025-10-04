import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:neighbours/core/components/custom_gap.dart';
import 'package:neighbours/core/components/default_app_bar.dart';
import 'package:neighbours/core/components/default_tab_bar.dart';
import 'package:neighbours/core/cubits/user/user_cubit.dart';
import 'package:neighbours/features/chat/presentation/widgets/community_chat_list_item.dart';
import 'package:neighbours/features/chat/presentation/widgets/private_chat_list_item.dart';
import 'package:neighbours/features/chat/presentation/cubits/private_message/private_message_cubit.dart';
import 'package:neighbours/features/community/domain/entities/community/community_entity.dart';
import 'package:neighbours/features/event/domain/entities/event/event_entity.dart';
import 'package:neighbours/features/event/presentation/cubits/events/events_cubit.dart';
import '../widgets/event_chat_list_item.dart';

class ChatList extends StatelessWidget {
  const ChatList({super.key});

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
    return BlocBuilder<PrivateMessageCubit, PrivateMessageState>(
      builder: (context, state) {
        // TODO: Здесь нужно будет получать список бесед из API
        // Пока что показываем заглушку
        final privateConversations = <Map<String, dynamic>>[];
        
        if (privateConversations.isEmpty) {
          return const Center(
            child: Text('Пока нет личных сообщений'),
          );
        }

        return ListView.builder(
          itemBuilder: (context, index) {
            final conversation = privateConversations[index];
            return PrivateChatListItem(
              conversationId: conversation['conversationId'],
              interlocutor: conversation['interlocutor'],
              lastMessage: conversation['lastMessage'],
              lastMessageTime: conversation['lastMessageTime'],
            );
          },
          itemCount: privateConversations.length,
        );
      },
    );
  }
}
