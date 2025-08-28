import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:neighbours/core/constants/ui_constants.dart';
import 'package:neighbours/core/cubits/events/events_cubit.dart';
import 'package:neighbours/core/domain/entities/event/event_entity.dart';
import 'package:neighbours/core/extensions/context_ext.dart';
import 'package:neighbours/core/state/api_state.dart';
import 'package:neighbours/features/community/presentation/widgets/error_with_try_btn.dart';
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

        // данные
        final List<EventEntity> items = state.notifications.values.toList();

        return DateGroupedList<EventEntity>(
          items: items,
          dateOf: (e) => e.createdAt,
          itemBuilder: (ctx, e) => NotificationCard(event: e),
          // новые сверху
          sortDescending: true,
          // "Сегодня/Вчера"
          showTodayYesterday: true,
          // локаль на формат даты
          dateLocale: 'ru_RU',
          // как раньше: только горизонтальный паддинг
          padding: const EdgeInsets.symmetric(
            horizontal: UIConstants.defaultHorizontalPadding,
            vertical: 8,
          ),
          itemSpacing: 8,
          // Кастомный заголовок как в исходнике (без Divider)
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
