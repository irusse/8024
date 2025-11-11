import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:neighbours/core/components/custom_button.dart';
import 'package:neighbours/core/components/custom_gap.dart';
import 'package:neighbours/core/components/custom_svg.dart';
import 'package:neighbours/core/components/default_app_bar.dart';
import 'package:neighbours/core/components/default_loading_overlay.dart';
import 'package:neighbours/core/constants/assets.dart';
import 'package:neighbours/core/extensions/context_ext.dart';
import 'package:neighbours/core/state/api_state.dart';
import 'package:neighbours/features/notification/domain/entities/notification/notification_entity.dart';
import 'package:neighbours/features/notification/presentation/cubits/notification_cubit.dart';
import 'package:neighbours/features/notification/presentation/widgets/notification_item.dart';
import 'package:neighbours/core/components/error_with_try_btn.dart';

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key});

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  late final ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _scrollController.addListener(_onScroll);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<NotificationCubit>().fetchNotifications();
    });
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      context.read<NotificationCubit>().loadMoreNotifications();
    }
  }

  @override
  Widget build(BuildContext context) {
    final hasNotifications = context.select<NotificationCubit, bool>(
        (cubit) => cubit.state.notifications.isNotEmpty);
    return Scaffold(
      appBar: DefaultAppBar(
        showBackButton: true,
        title: 'Уведомления',
        actions: [
          if (hasNotifications)
            CustomButton(
              onPressed: () =>
                  context.read<NotificationCubit>().deleteAllNotifications(),
              svgIcon: CustomSvg(
                asset: Assets.icons.delete,
                color: context.color.basicRed,
                width: 20,
                height: 20,
              ),
            )
        ],
      ),
      body: BlocConsumer<NotificationCubit, NotificationState>(
        listener: (context, state) {
          state.fetchState.maybeWhen(
            failure: (message) {
              context.snackbar.error(context, message);
            },
            orElse: () {},
          );
          state.deleteAllState.handleApiState(
            onError: (message) {
              context.snackbar.error(context, message);
            },
            onSuccess: () => context.snackbar
                .success(context, "Уведомления успешно удалены"),
          );
          state.loadMoreState.maybeWhen(
            failure: (message) {
              context.snackbar.error(context, message);
            },
            orElse: () {},
          );
        },
        builder: (context, state) {
          return Stack(
            children: [
              if (state.fetchState.isSuccess && state.notifications.isEmpty)
                Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.notifications_none_rounded,
                        size: 64,
                        color: context.color.secondaryText,
                      ),
                      const VerticalGap(16),
                      Text('Уведомлений нет',
                          style: context.text.bodyLarge
                              .copyWith(color: context.color.secondaryText)),
                    ],
                  ),
                ),
              ListView.builder(
                controller: _scrollController,
                itemCount: state.notifications.length + (state.hasMore ? 1 : 0),
                itemBuilder: (context, index) {
                  if (index >= state.notifications.length) {
                    // Показываем индикатор загрузки в конце списка
                    return state.isLoadingMore
                        ? const Padding(
                            padding: EdgeInsets.all(16.0),
                            child: Center(
                              child: CircularProgressIndicator(),
                            ),
                          )
                        : const SizedBox.shrink();
                  }
                  final NotificationEntity entity = state.notifications[index];
                  return NotificationItem(entity: entity);
                },
              ),
              if (state.fetchState.isLoading)
                const DefaultLoadingOverlay(transparent: true),
              if (state.fetchState.isFailure)
                ErrorWithTryBtn(
                  error: state.fetchState.error!,
                  onErrorClick: () =>
                      context.read<NotificationCubit>().fetchNotifications(),
                ),
            ],
          );
        },
      ),
    );
  }
}
