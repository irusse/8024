import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:neighbours/core/components/custom_gap.dart';
import 'package:neighbours/core/components/custom_outlined_button.dart';
import 'package:neighbours/core/components/default_loading_overlay.dart';
import 'package:neighbours/core/components/primary_button.dart';
import 'package:neighbours/core/router/app_routes.dart';
import 'package:neighbours/core/state/api_state.dart';
import 'package:neighbours/features/community/presentation/widgets/notification_card.dart';
import 'package:neighbours/features/event/domain/entities/event/event_entity.dart';
import 'package:neighbours/features/event/presentation/cubits/events/events_cubit.dart';
import '../../../event/presentation/widgets/location_address_view.dart';

class NotificationInfoDialog extends StatelessWidget {
  final int userId;
  final int eventId;
  final ValueChanged<int> onNotRelevantClick;

  const NotificationInfoDialog(
      {super.key,
      required this.eventId,
      required this.userId,
      required this.onNotRelevantClick});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<EventsCubit, EventsState>(
      buildWhen: (prev, curr) =>
          prev.joinEventState != curr.joinEventState ||
          prev.leaveEventState != curr.leaveEventState,
      builder: (context, state) {
        final notification = state.events[eventId];
        if (notification == null) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (context.mounted && context.canPop()) context.pop();
          });
          return const SizedBox.shrink();
        }

        final isCreator = notification.isCreator(userId);
        final isParticipant = notification.isParticipant(userId);

        return Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            NotificationCard(
              event: notification,
              isClickable: false,
            ),
            const VerticalGap(8),
            LocationAddressView(
              longitude: notification.longitude,
              latitude: notification.latitude,
              maxLines: 1,
            ),
            const VerticalGap(16),
            _bottom(context,
                eventId: notification.id,
                isCreator: isCreator,
                isParticipant: isParticipant,
                eventTitle: notification.title,
                state: state),
            const VerticalGap(8),
          ],
        );
      },
    );
  }

  Widget _bottom(
    BuildContext context, {
    required int eventId,
    required String eventTitle,
    required bool isCreator,
    required bool isParticipant,
    required EventsState state,
  }) {
    if (isCreator) {
      return Row(
        children: [
          Expanded(
              child: CustomOutlinedButton(
            onPressed: () => onNotRelevantClick(eventId),
            text: 'Не актуально',
            verticalPadding: 12,
          )),
          const HorizontalGap(16),
          Expanded(
              child: CustomOutlinedButton(
            onPressed: () =>
                context.push(AppRouteBuilder.chatPage(eventId, eventTitle)),
            text: 'Чат',
            verticalPadding: 12,
          )),
        ],
      );
    } else if (isParticipant) {
      return state.leaveEventState.isLoading
          ? const DefaultLoadingOverlay(
              transparent: true,
            )
          : Row(
              children: [
                Expanded(
                    child: CustomOutlinedButton(
                        verticalPadding: 12,
                        onPressed: () {
                          context
                              .read<EventsCubit>()
                              .leaveEvent(eventId: eventId.toString());
                        },
                        text: 'Не участвую')),
                const HorizontalGap(16),
                Expanded(
                  child: CustomOutlinedButton(
                    onPressed: () => context
                        .push(AppRouteBuilder.chatPage(eventId, eventTitle)),
                    text: 'Чат',
                    verticalPadding: 12,
                  ),
                ),
              ],
            );
    } else {
      return PrimaryButton(
        text: 'Я участвую',
        onPressed: () {
          context.read<EventsCubit>().joinEvent(eventId: eventId.toString());
        },
        isLoading: state.joinEventState.isLoading,
        verticalPadding: 12,
      );
    }
  }
}
