import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:neighbours/core/components/custom_gap.dart';
import 'package:neighbours/core/extensions/context_ext.dart';
import 'package:neighbours/core/router/app_routes.dart';
import 'package:neighbours/core/state/api_state.dart';

import '../../../../core/constants/ui_constants.dart';
import '../../../../core/cubits/events/events_cubit.dart';
import 'error_with_try_btn.dart';
import 'event_card.dart';

class EventsTab extends StatelessWidget {
  final int communityId;

  const EventsTab({super.key, required this.communityId});

  @override
  Widget build(BuildContext context) {
    return BlocListener<EventsCubit, EventsState>(
      listenWhen: (prev, curr) => prev.deleteState != curr.deleteState,
      listener: (context, state) {
        if (state.deleteState.isSuccess) {
          context.snackbar.info(context, 'Мероприятие успешно удалено');
        }
        if (state.deleteState.isFailure) {
          context.snackbar.error(context, state.deleteState.error!);
        }
      },
      child: RefreshIndicator(
        onRefresh: () => context
            .read<EventsCubit>()
            .fetchCommunityEvents(communityId: communityId.toString()),
        child: Stack(
          children: [
            CustomScrollView(
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

                    final values = state.events.values.toList();

                    return SliverPadding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: UIConstants.defaultHorizontalPadding,
                      ),
                      sliver: SliverList(
                        delegate: SliverChildBuilderDelegate(
                          (context, index) {
                            final event = values[index];
                            return EventCard(event: event);
                          },
                          childCount: values.length,
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

            /// Floating Action Button
            Positioned(
              bottom: 16,
              right: 16,
              child: FloatingActionButton(
                backgroundColor: context.color.primary,
                onPressed: () => context.push(AppRoutePath.eventForm),
                child: const Icon(Icons.add, color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
