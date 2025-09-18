import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:neighbours/core/components/custom_gap.dart';
import 'package:neighbours/core/components/default_app_bar.dart';
import 'package:neighbours/core/components/default_loading_overlay.dart';
import 'package:neighbours/core/cubits/user/user_cubit.dart';
import 'package:neighbours/core/extensions/context_ext.dart';
import 'package:neighbours/core/state/api_state.dart';
import 'package:neighbours/features/community/presentation/widgets/error_with_try_btn.dart';

import '../../../../core/services/snackbar_service.dart';
import '../cubits/community/community_cubit.dart';
import '../widgets/notifications_tab.dart';
import '../widgets/events_tab.dart';
import '../widgets/users_tab.dart';

class Community extends StatefulWidget {
  final int communityId;

  const Community({
    super.key,
    required this.communityId,
  });

  @override
  State<Community> createState() => _CommunityState();
}

class _CommunityState extends State<Community> {
  @override
  void initState() {
    super.initState();
    final communityCubit = context.read<CommunityCubit>();
    final userCubit = context.read<UserCubit>();

    // ищем сообщество среди уже загруженных у пользователя
    final existingCommunity = userCubit.state.user.communities.firstWhereOrNull(
      (c) => c.id == widget.communityId,
    );

    if (existingCommunity != null) {
      // если нашли — сразу обновляем cubit
      communityCubit.updateCommunity(existingCommunity);
    } else {
      // если не нашли — грузим с сервера
      communityCubit.getCommunityById(widget.communityId);
    }

    // в фоне всё равно грузим участников
    communityCubit.fetchCommunityParticipants(widget.communityId);
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CommunityCubit, CommunityState>(
      builder: (context, state) {
        final communityEntity = state.community;
        final shouldShowFullScreenLoading =
            communityEntity.id == 0 && state.fetchCommunityState.isLoading;

        if (shouldShowFullScreenLoading) {
          return const Scaffold(body: DefaultLoadingOverlay());
        }

        // Ошибка + нет данных
        if (state.fetchCommunityState.isFailure && communityEntity.id == 0) {
          return Scaffold(
            appBar: const DefaultAppBar(
              title: 'Ошибка',
              showBackButton: true,
            ),
            body: ErrorWithTryBtn(
              error: 'Не удалось загрузить данные сообщества',
              onErrorClick: () => context
                  .read<CommunityCubit>()
                  .getCommunityById(widget.communityId),
            ),
          );
        }

        final numberOfParticipants = state.participants.length;
        final usersTabTitle = state.participantsState.isLoading ||
                state.participantsState.isFailure
            ? 'Участники'
            : 'Участники $numberOfParticipants';

        return Scaffold(
          appBar: DefaultAppBar(
            height: 72,
            showBackButton: true,
            titleWidget: Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Text(
                      communityEntity.name,
                      overflow: TextOverflow.ellipsis,
                      style: context.text.titleSmall,
                    ),
                  ),
                  const VerticalGap(4),
                  Text(
                    'ID: ${communityEntity.id}',
                    style: context.text.bodySmall
                        .copyWith(color: context.color.secondaryText),
                  ),
                ],
              ),
            ),
            actions: [
              GestureDetector(
                child: Text(
                  communityEntity.joinCode,
                  style: context.text.bodyMedium.copyWith(
                    color: context.color.primary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                onTap: () {
                  Clipboard.setData(
                    ClipboardData(text: communityEntity.joinCode),
                  ).then((_) {
                    if (context.mounted) {
                      context.snackbar.info(
                        context,
                        'Скопировано в буфер обмена',
                        position: SnackBarPosition.bottom,
                      );
                    }
                  });
                },
              )
            ],
          ),
          body: DefaultTabController(
            length: 3,
            child: Column(
              children: [
                TabBar(
                  tabs: [
                    const Tab(text: 'Оповещения'),
                    const Tab(text: 'Мероприятия'),
                    Tab(text: usersTabTitle),
                  ],
                  labelStyle: context.text.bodyMedium
                      .copyWith(fontWeight: FontWeight.w500),
                  unselectedLabelStyle: context.text.bodyMedium.copyWith(
                    fontWeight: FontWeight.w500,
                    color: context.color.secondaryText,
                  ),
                  indicatorPadding: EdgeInsets.zero,
                  indicatorColor: context.color.primary,
                  padding: EdgeInsets.zero,
                  labelPadding: EdgeInsets.zero,
                  dividerColor: context.color.secondary,
                ),
                Expanded(
                  child: TabBarView(
                    children: [
                      NotificationsTab(
                        communityDescription: communityEntity.description,
                        communityId: communityEntity.id,
                      ),
                      EventsTab(
                        communityId: communityEntity.id,
                      ),
                      UsersTab(
                        communityId: communityEntity.id,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
