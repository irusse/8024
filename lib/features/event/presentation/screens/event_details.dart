import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:neighbours/core/components/bottom_sheet_dialog.dart';
import 'package:neighbours/core/components/bottom_sheet_option.dart';
import 'package:neighbours/core/components/custom_button.dart';
import 'package:neighbours/core/components/custom_gap.dart';
import 'package:neighbours/core/components/custom_svg.dart';
import 'package:neighbours/core/components/default_app_bar.dart';
import 'package:neighbours/core/components/default_loading_overlay.dart';
import 'package:neighbours/core/components/default_tab_bar.dart';
import 'package:neighbours/core/components/shaped_cached_image.dart';
import 'package:neighbours/core/constants/ui_constants.dart';
import 'package:neighbours/core/cubits/events/events_cubit.dart';
import 'package:neighbours/core/cubits/user/user_cubit.dart';
import 'package:neighbours/core/domain/entities/event/event_entity.dart';
import 'package:neighbours/core/extensions/context_ext.dart';
import 'package:neighbours/core/router/app_routes.dart';
import 'package:neighbours/core/state/api_state.dart';
import 'package:neighbours/features/community/presentation/widgets/error_with_try_btn.dart';
import 'package:neighbours/features/event/presentation/cubits/vote/vote_cubit.dart';
import 'package:neighbours/features/event/presentation/widgets/chat_tab.dart';
import 'package:neighbours/features/event/presentation/widgets/default_divider.dart';
import 'package:neighbours/features/event/presentation/widgets/event_participants_tab.dart';

import '../../../../core/components/custom_alert_dialog.dart';
import '../../../../core/constants/assets.dart';
import '../widgets/event_info_tab.dart';
import '../widgets/participate_button.dart';

class EventDetails extends StatefulWidget {
  final String eventId;

  const EventDetails({
    super.key,
    required this.eventId,
  });

  @override
  State<EventDetails> createState() => _EventDetailsState();
}

class _EventDetailsState extends State<EventDetails> {
  @override
  void initState() {
    super.initState();
    // всегда пытаемся обновить данные
    context.read<EventsCubit>().fetchEventById(eventId: widget.eventId);
  }

  Future<void> _onDeleteClick(BuildContext context, int eventId) async {
    final deleteConfirm = await showDialog<bool>(
      context: context,
      builder: (context) => CustomAlertDialog(
        title: 'Удалить мероприятие?',
        content: 'Вы уверены, что хотите удалить выбранное мероприятие?',
        confirmText: 'Да',
        isConfirmDestructive: true,
        onCancel: () => Navigator.pop(context, false),
        onConfirm: () => Navigator.pop(context, true),
      ),
    );

    if (deleteConfirm == true && context.mounted) {
      context.read<EventsCubit>().deleteEvent(eventId: eventId.toString());
      context.pop();
    }
  }

  void _onOptionsClick(
      BuildContext context, EventEntity event, bool isCreator) {
    showBaseBottomSheet(
      context: context,
      child: Column(
        children: [
          BottomSheetOption(
            text: 'Поделиться',
            onClick: () {},
            iconPath: Assets.icons.share,
          ),
          BottomSheetOption(
            text: 'Пожаловаться',
            onClick: () {},
            iconPath: Assets.icons.warning,
          ),
          if (isCreator)
            BottomSheetOption(
              text: 'Редактировать',
              onClick: () {
                context.pop();
                context.push(AppRoutePath.eventForm, extra: event);
              },
              iconPath: Assets.icons.edit,
            ),
          if (isCreator)
            BottomSheetOption(
              text: 'Удалить',
              onClick: () => _onDeleteClick(context, event.id),
              iconPath: Assets.icons.delete,
              isDelete: true,
            ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<EventsCubit, EventsState>(
      listener: (context, state) {
        state.deleteState.handleApiState(
          onSuccess: () => context.pop(),
          onError: (error) => context.snackbar.error(context, error),
        );
        state.joinEventState.handleApiState(
          onSuccess: () =>
              context.snackbar.success(context, 'Вы вступили в мероприятие'),
          onError: (error) => context.snackbar.error(context, error),
        );
        state.leaveEventState.handleApiState(
          onSuccess: () {
            context.snackbar.info(context, 'Вы покинули мероприятие');
            final voteCubit = context.read<VoteCubit>();
            final results = voteCubit.state.votingResults;
            final event =
                state.events[int.parse(widget.eventId)]; // свежие данные
            if (event != null && results?.hasVoted == true) {
              voteCubit.cancelVote(eventId: event.id);
            }
          },
          onError: (error) => context.snackbar.error(context, error),
        );
      },
      builder: (context, state) {
        final event = state.events[int.parse(widget.eventId)];

        // Показываем загрузку если события вообще нет
        if (event == null && state.fetchEventByIdState.isLoading) {
          return const Scaffold(body: DefaultLoadingOverlay());
        }

        // Ошибка если не удалось загрузить
        if (event == null && state.fetchEventByIdState.isFailure) {
          return Scaffold(
            body: ErrorWithTryBtn(
              error: "Что-то пошло не так\nВозможно событие удалено",
              onErrorClick: () => context
                  .read<EventsCubit>()
                  .fetchEventById(eventId: widget.eventId),
            ),
          );
        }

        if (event == null) {
          return const SizedBox(); // fallback
        }

        final userId = context.read<UserCubit>().state.user.id;
        final participants = [event.creator, ...event.participants];
        final tabs = [
          'Информация',
          'Участники (${participants.length})',
          'Чат'
        ];

        return DefaultTabController(
          length: tabs.length,
          child: Stack(
            children: [
              Scaffold(
                appBar: DefaultAppBar(
                  showBackButton: true,
                  title: event.title,
                  actions: [
                    CustomButton(
                      onPressed: () => _onOptionsClick(
                          context, event, event.isCreator(userId)),
                      svgIcon: CustomSvg(
                        asset: Assets.icons.option,
                        color: context.color.secondaryText,
                      ),
                    )
                  ],
                ),
                body: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: UIConstants.defaultHorizontalPadding),
                      child: Column(
                        children: [
                          ShapedCachedImage(
                            width: double.infinity,
                            url: event.image,
                            radius: 56,
                          ),
                          const VerticalGap(16),
                          ParticipateButton(
                            eventId: event.id,
                            isCreator: event.isCreator(userId),
                            isParticipant: event.isParticipant(userId),
                            joinState: state.joinEventState,
                            leaveState: state.leaveEventState,
                          ),
                        ],
                      ),
                    ),
                    const VerticalGap(16),
                    const DefaultDivider(),
                    const VerticalGap(8),
                    DefaultTabBar(tabs: tabs),
                    const VerticalGap(8),
                    const DefaultDivider(),
                    const VerticalGap(8),
                    Expanded(
                      child: TabBarView(
                        children: [
                          EventInfoTab(event: event),
                          EventParticipantsTab(participants: participants),
                          ChatTab(
                            eventId: event.id,
                            isChatAvailable: event.isCreator(userId) ||
                                event.isParticipant(userId),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              if (state.deleteState.isLoading)
                const DefaultLoadingOverlay(),
            ],
          ),
        );
      },
    );
  }
}
