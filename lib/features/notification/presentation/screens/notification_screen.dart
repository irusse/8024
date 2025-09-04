import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:neighbours/core/components/custom_gap.dart';
import 'package:neighbours/core/components/default_app_bar.dart';
import 'package:neighbours/core/components/default_loading_overlay.dart';
import 'package:neighbours/core/extensions/context_ext.dart';
import 'package:neighbours/core/state/api_state.dart';
import 'package:neighbours/features/notification/domain/entities/notification/notification_entity.dart';
import 'package:neighbours/features/notification/presentation/cubits/notification_cubit.dart';
import 'package:neighbours/features/notification/presentation/widgets/notification_item.dart';
import 'package:neighbours/features/community/presentation/widgets/error_with_try_btn.dart';

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key});

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<NotificationCubit>().fetchNotifications();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const DefaultAppBar(
        showBackButton: true,
        title: 'Уведомления',
      ),
      body: BlocConsumer<NotificationCubit, NotificationState>(
        listener: (context, state) {
          state.fetchState.maybeWhen(
            failure: (message) {
              context.snackbar.error(context, message);
            },
            orElse: () {},
          );
        },
        builder: (context, state) {
          return Stack(
            children: [
              ListView.builder(
                itemCount: state.notifications.length,
                itemBuilder: (context, index) {
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
