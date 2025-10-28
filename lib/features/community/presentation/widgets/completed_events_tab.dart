import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:neighbours/core/components/custom_gap.dart';
import 'package:neighbours/core/extensions/context_ext.dart';
import 'package:neighbours/core/state/api_state.dart';
import 'package:neighbours/features/event/domain/entities/event/event_entity.dart';
import 'package:neighbours/features/event/presentation/cubits/events/events_cubit.dart';

import '../../../../core/constants/ui_constants.dart';
import '../../../event/presentation/widgets/completed_event_card.dart';
import 'error_with_try_btn.dart';

class CompletedEventsTab extends StatelessWidget {
  final int communityId;

  const CompletedEventsTab({super.key, required this.communityId});

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: () => context
          .read<EventsCubit>()
          .fetchCommunityEvents(communityId: communityId.toString()),
      child: CustomScrollView(
        slivers: [
          const SliverToBoxAdapter(
            child: VerticalGap(8),
          ),
          BlocBuilder<EventsCubit, EventsState>(
            builder: (context, state) {
              if (state.fetchState.isLoading) {
                return SliverToBoxAdapter(
                  child: Center(
                    child: CircularProgressIndicator(
                      color: context.color.primary,
                    ),
                  ),
                );
              }

              if (state.fetchState.isFailure) {
                return SliverToBoxAdapter(
                  child: ErrorWithTryBtn(
                    error: state.fetchState.error!,
                    onErrorClick: () => context
                        .read<EventsCubit>()
                        .fetchCommunityEvents(
                            communityId: communityId.toString()),
                  ),
                );
              }

              // Получаем только завершенные события
              final allEvents = context.read<EventsCubit>().allFullEvents();
              final completedEvents =
                  allEvents.where((event) => event.isCompleted).toList();

              // Сортируем по дате создания (новые сверху)
              completedEvents
                  .sort((a, b) => b.createdAt.compareTo(a.createdAt));

              if (completedEvents.isEmpty) {
                return SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(32),
                    child: Column(
                      children: [
                        Icon(
                          Icons.event_available_outlined,
                          size: 64,
                          color:
                              context.color.secondaryText.withValues(alpha: .3),
                        ),
                        const VerticalGap(16),
                        Text(
                          'Нет завершенных мероприятий',
                          style: context.text.titleSmall.copyWith(
                            color: context.color.secondaryText
                                .withValues(alpha: .6),
                          ),
                        ),
                        const VerticalGap(8),
                        Text(
                          'Завершенные мероприятия появятся здесь',
                          style: context.text.bodyMedium.copyWith(
                            color: context.color.secondaryText
                                .withValues(alpha: .4),
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                );
              }

              return SliverPadding(
                padding: const EdgeInsets.symmetric(
                  horizontal: UIConstants.defaultHorizontalPadding,
                ),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final event = completedEvents[index];
                      return CompletedEventCard(event: event);
                    },
                    childCount: completedEvents.length,
                  ),
                ),
              );
            },
          ),
          const SliverToBoxAdapter(
            child: VerticalGap(72),
          ),
        ],
      ),
    );
  }
}
