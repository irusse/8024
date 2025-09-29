import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:neighbours/core/components/custom_gap.dart';
import 'package:neighbours/core/components/default_app_bar.dart';
import 'package:neighbours/core/components/default_tab_bar.dart';
import 'package:neighbours/core/cubits/user/user_cubit.dart';
import 'package:neighbours/features/chat/presentation/widgets/community_chat_list_item.dart';
import 'package:neighbours/features/event/presentation/cubits/events/events_cubit.dart';
import '../widgets/event_chat_list_item.dart';

class ChatList extends StatelessWidget {
  const ChatList({super.key});

  @override
  Widget build(BuildContext context) {
    final userId = context.read<UserCubit>().state.user.id;
    final allUserEvents = context.read<EventsCubit>().allUserFullEvents(userId);
    final allUserNotifications =
        context.read<EventsCubit>().allUserNotifications(userId);
    final communities = context.read<UserCubit>().state.user.communities;
    return Scaffold(
      appBar: const DefaultAppBar(
        showBackButton: true,
        title: 'Чаты',
      ),
      body: DefaultTabController(
        length: 2,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const DefaultTabBar(
                tabs: ["Сообщества", "Мероприятия", "Оповещения"]),
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
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
