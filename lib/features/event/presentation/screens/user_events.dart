import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:neighbours/core/components/default_app_bar.dart';
import 'package:neighbours/core/components/default_tab_bar.dart';
import 'package:neighbours/core/cubits/user/user_cubit.dart';
import 'package:neighbours/core/extensions/context_ext.dart';
import 'package:neighbours/features/community/presentation/widgets/event_card.dart';
import 'package:neighbours/features/community/presentation/widgets/notification_card.dart';
import 'package:neighbours/features/event/domain/entities/event/event_entity.dart';
import 'package:neighbours/features/event/presentation/cubits/events/events_cubit.dart';

import '../../../../core/components/custom_gap.dart';
import '../../../../core/components/date_grouped_list.dart';
import '../widgets/default_divider.dart';

class UserEvents extends StatefulWidget {
  const UserEvents({super.key});

  @override
  State<UserEvents> createState() => _UserEventsState();
}

class _UserEventsState extends State<UserEvents> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final userId = context.read<UserCubit>().state.user.id;
    return Scaffold(
      appBar: const DefaultAppBar(
        showBackButton: true,
        title: 'Мои события',
      ),
      body: DefaultTabController(
        length: 2,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const DefaultDivider(),
            const VerticalGap(8),
            const DefaultTabBar(tabs: ['Мои', 'Участвую']),
            const VerticalGap(8),
            const DefaultDivider(),
            const VerticalGap(8),
            BlocBuilder<EventsCubit, EventsState>(
              builder: (context, state) {
                return Expanded(
                  child: TabBarView(
                    children: [
                      _userCreatedEvents(context, userId),
                      _userParticipantEvents(context, userId)
                    ],
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _userCreatedEvents(BuildContext context, int userId) {
    final myEvents = context.read<EventsCubit>().userCreatedEvents(userId);
    return DateGroupedList<EventEntity>(
      items: myEvents,
      dateOf: (obj) => obj.createdAt,
      itemBuilder: (context, event) {
        if (event.isFullEvent) return EventCard(event: event);
        if (event.isNotification) return NotificationCard(event: event);
        return const SizedBox.shrink();
      },
      // Опционально можно кастомизировать вид заголовка:
      headerBuilder: (context, date, title) => Center(
        child: Text(
          title,
          style: context.text.bodyMedium
              .copyWith(color: context.color.secondaryText),
        ),
      ),
    );
  }

  Widget _userParticipantEvents(BuildContext context, int userId) {
    final userParticipantEvents =
        context.read<EventsCubit>().userParticipatedEvents(userId);

    return DateGroupedList<EventEntity>(
      items: userParticipantEvents,
      dateOf: (obj) => obj.createdAt,
      itemBuilder: (context, event) {
        if (event.isFullEvent) return EventCard(event: event);
        if (event.isNotification) return NotificationCard(event: event);
        return const SizedBox.shrink();
      },
      headerBuilder: (context, date, title) => Center(
        child: Text(
          title,
          style: context.text.bodyMedium
              .copyWith(color: context.color.secondaryText),
        ),
      ),
    );
  }
}
