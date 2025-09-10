import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:neighbours/core/components/custom_gap.dart';
import 'package:neighbours/core/components/default_app_bar.dart';
import 'package:neighbours/core/extensions/context_ext.dart';
import 'package:neighbours/core/state/api_state.dart';
import 'package:neighbours/features/community/domain/entities/community/community_entity.dart';

import '../../../../core/services/snackbar_service.dart';
import '../cubits/community/community_cubit.dart';
import '../widgets/notifications_tab.dart';
import '../widgets/events_tab.dart';
import '../widgets/users_tab.dart';

class Community extends StatefulWidget {
  final int communityId;
  final CommunityEntity? communityEntity;

  const Community({
    super.key,
    required this.communityId,
    this.communityEntity,
  });

  @override
  State<Community> createState() => _CommunityState();
}

class _CommunityState extends State<Community> {
  @override
  void initState() {
    super.initState();
    final cubit = context.read<CommunityCubit>();

    // Если есть переданное сообщество, устанавливаем его сразу
    if (widget.communityEntity != null) {
      cubit.updateCommunity(widget.communityEntity!);
    } else {
      cubit.getCommunityById(widget.communityId);
    }

    // Всегда загружаем свежие данные с сервера в фоне
    cubit.fetchCommunityParticipants(widget.communityId);
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CommunityCubit, CommunityState>(
      builder: (context, state) {
        final communityEntity = state.community;
        final shouldShowFullScreenLoading = widget.communityEntity == null &&
            state.fetchCommunityState.isLoading;

        if (shouldShowFullScreenLoading) {
          return Scaffold(
            appBar: AppBar(
              title: const Text('Загрузка...'),
              backgroundColor: Colors.transparent,
              elevation: 0,
            ),
            body: const Center(
              child: CircularProgressIndicator(),
            ),
          );
        }

        // Если произошла ошибка и нет данных для отображения
        if (state.fetchCommunityState.isFailure && communityEntity.id == 0) {
          return Scaffold(
            appBar: AppBar(
              title: const Text('Ошибка'),
              backgroundColor: Colors.transparent,
              elevation: 0,
            ),
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Не удалось загрузить данные сообщества',
                    style: context.text.bodyLarge,
                    textAlign: TextAlign.center,
                  ),
                  const VerticalGap(16),
                  ElevatedButton(
                    onPressed: () {
                      context
                          .read<CommunityCubit>()
                          .getCommunityById(widget.communityId);
                    },
                    child: const Text('Повторить'),
                  ),
                ],
              ),
            ),
          );
        }

        final numberOfParticipants = state.participants.length;
        String usersTabTitle;
        if (state.participantsState.isLoading ||
            state.participantsState.isFailure) {
          usersTabTitle = 'Участники';
        } else {
          usersTabTitle = 'Участники $numberOfParticipants';
        }

        // Основной UI с данными сообщества
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
                )),
                const VerticalGap(4),
                Text(
                  'ID: ${communityEntity.id.toString()}',
                  style: context.text.bodySmall
                      .copyWith(color: context.color.secondaryText),
                ),
              ],
            )),
            actions: [
              GestureDetector(
                child: Text(
                  communityEntity.joinCode,
                  style: context.text.bodyMedium.copyWith(
                      color: context.color.primary,
                      fontWeight: FontWeight.w500),
                ),
                onTap: () {
                  Clipboard.setData(
                          ClipboardData(text: communityEntity.joinCode))
                      .then((_) {
                    if (context.mounted) {
                      context.snackbar.info(
                          context, 'Скопировано в буфер обмена',
                          position: SnackBarPosition.bottom);
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
                      color: context.color.secondaryText),
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
