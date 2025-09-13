import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:neighbours/core/constants/ui_constants.dart';
import 'package:neighbours/core/extensions/context_ext.dart';
import 'package:neighbours/core/state/api_state.dart';
import 'package:neighbours/features/community/presentation/widgets/error_with_try_btn.dart';
import 'package:neighbours/features/event/domain/entities/event/event_entity.dart';
import 'package:neighbours/features/event/presentation/cubits/events/events_cubit.dart';
import '../../../../core/components/date_grouped_list.dart';
import 'notification_card.dart';

class NotificationsTab extends StatelessWidget {
  final int communityId;
  final String? communityDescription;

  const NotificationsTab({
    super.key,
    required this.communityDescription,
    required this.communityId,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<EventsCubit, EventsState>(
      builder: (context, state) {
        if (state.fetchState.isLoading) {
          return Center(
            child: CircularProgressIndicator(color: context.color.primary),
          );
        }

        if (state.fetchState.isFailure) {
          return ErrorWithTryBtn(
            error: state.fetchState.error!,
            onErrorClick: () => context
                .read<EventsCubit>()
                .fetchCommunityEvents(communityId: communityId.toString()),
          );
        }

        return DateGroupedList<EventEntity>(
          items: context.read<EventsCubit>().allNotifications(),
          dateOf: (e) => e.createdAt,
          itemBuilder: (ctx, e) => NotificationCard(event: e,),
          sortDescending: true,
          showTodayYesterday: true,
          dateLocale: 'ru_RU',
          padding: const EdgeInsets.symmetric(
            horizontal: UIConstants.defaultHorizontalPadding,
            vertical: 8,
          ),
          itemSpacing: 8,
          headerBuilder: (ctx, date, title) => Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Text(
              title,
              style: context.text.labelLarge.copyWith(
                fontWeight: FontWeight.w600,
                color: context.color.secondaryText,
              ),
            ),
          ),
        );
      },
    );
  }
}
