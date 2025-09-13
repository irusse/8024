import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:neighbours/core/components/bottom_sheet_dialog.dart';
import 'package:neighbours/core/components/bottom_sheet_option.dart';
import 'package:neighbours/core/cubits/user/user_cubit.dart';
import 'package:neighbours/core/extensions/context_ext.dart';
import 'package:neighbours/core/router/app_routes.dart';
import 'package:neighbours/features/event/domain/entities/event/event_entity.dart';
import 'package:neighbours/features/event/presentation/cubits/events/events_cubit.dart';

import '../../../../core/components/custom_alert_dialog.dart';
import '../../../../core/components/custom_gap.dart';
import '../../../../core/constants/assets.dart';

class NotificationCard extends StatelessWidget {
  final EventEntity event;
  final bool isClickable;

  const NotificationCard(
      {super.key, required this.event, this.isClickable = true});

  Future<void> _onDeleteClick(BuildContext context) async {
    context.pop();
    final logoutConfirm = await showDialog<bool>(
      context: context,
      builder: (context) => CustomAlertDialog(
        title: 'Удаление',
        content: 'Вы уверены, что хотите удалить оповещение?',
        confirmText: 'Да',
        isConfirmDestructive: true,
        onCancel: () => Navigator.pop(context, false),
        onConfirm: () => Navigator.pop(context, true),
      ),
    );

    if (logoutConfirm == true && context.mounted) {
      context.read<EventsCubit>().deleteEvent(eventId: event.id.toString());
    }
  }

  void _showBottomSheet(BuildContext context) {
    final userId = context.read<UserCubit>().state.user.id;
    if (userId != event.creator.id) return;
    showBaseBottomSheet(
        context: context,
        child: Column(
          children: [
            BottomSheetOption(
              onClick: () {
                context.pop();
                context.push(AppRoutePath.notificationForm, extra: event);
              },
              text: 'Редактировать',
              iconPath: Assets.icons.edit,
            ),
            BottomSheetOption(
              onClick: () => _onDeleteClick(context),
              text: 'Удалить',
              isDelete: true,
              iconPath: Assets.icons.delete,
            ),
          ],
        ));
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => isClickable ? _showBottomSheet(context) : {},
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: context.color.secondary,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                      "${_formatTime(event.createdAt)} • ${event.title} • ${event.creator.fullName}",
                      style: context.text.labelLarge
                          .copyWith(color: context.color.secondaryText)),
                  const VerticalGap(4),
                  Text(
                      event.description.isNotEmpty
                          ? event.description
                          : "Описание отсутсвует",
                      style: context.text.bodyLarge),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatTime(DateTime dateTime) {
    final hour = dateTime.hour.toString().padLeft(2, '0');
    final minute = dateTime.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }
}
