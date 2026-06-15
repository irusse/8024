import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:neighbours/core/extensions/context_ext.dart';
import 'package:neighbours/features/event/presentation/cubits/events/events_cubit.dart';

import '../../../../core/components/custom_alert_dialog.dart';
import '../../../../core/components/primary_button.dart';
import '../../../../core/state/api_state.dart';

class EventActionButton extends StatelessWidget {
  final int eventId;
  final bool isCreator;
  final bool isParticipant;
  final bool isCompleted;
  final ApiState joinState;
  final ApiState leaveState;
  final ApiState completeState;

  const EventActionButton(
      {super.key,
      required this.eventId,
      required this.isCreator,
      required this.isParticipant,
      required this.joinState,
      required this.leaveState,
      required this.completeState,
      required this.isCompleted});

  Future<void> _onLeaveClick(BuildContext context) async {
    final leaveConfirm = await showDialog<bool>(
      context: context,
      builder: (context) => CustomAlertDialog(
        title: 'Выйти?',
        content: 'Вы уверены, что хотите выйти из мероприятия?',
        confirmText: 'Да',
        isConfirmDestructive: true,
        onCancel: () => Navigator.pop(context, false),
        onConfirm: () => Navigator.pop(context, true),
      ),
    );

    if (leaveConfirm == true && context.mounted) {
      context.read<EventsCubit>().leaveEvent(eventId: eventId.toString());
    }
  }

  Future<void> _onFinishClick(BuildContext context) async {
    final completeConfirm = await showDialog<bool>(
      context: context,
      builder: (context) => CustomAlertDialog(
        title: 'Завершить?',
        content: 'Вы уверены, что хотите завершить мероприятие?',
        confirmText: 'Да',
        isConfirmDestructive: true,
        onCancel: () => Navigator.pop(context, false),
        onConfirm: () => Navigator.pop(context, true),
      ),
    );

    if (completeConfirm == true && context.mounted) {
      context.read<EventsCubit>().completeEvent(eventId: eventId.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    // Если мероприятие завершено, показываем плашку
    if (isCompleted) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        decoration: BoxDecoration(
          color: context.color.basicRed.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: context.color.basicRed.withValues(alpha: 0.3),
            width: 1,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.check_circle,
              color: context.color.basicRed,
              size: 20,
            ),
            const SizedBox(width: 8),
            Text('Мероприятие завершено',
                style: context.text.bodyMedium
                    .copyWith(color: context.color.basicRed)),
          ],
        ),
      );
    }

    if (isCreator) {
      return PrimaryButton(
        text: 'Завершить мероприятие',
        backgroundColor: context.color.basicRed,
        isLoading: completeState.isLoading,
        onPressed: () => _onFinishClick(context),
        verticalPadding: 10,
      );
    }
    if (isParticipant) {
      return PrimaryButton(
        text: 'Выйти из мероприятия',
        backgroundColor: context.color.basicRed,
        isLoading: leaveState.isLoading,
        onPressed: () => _onLeaveClick(context),
        verticalPadding: 10,
      );
    }

    return PrimaryButton(
      text: joinState.isLoading ? 'Ожидайте...' : 'Я участвую',
      isLoading: joinState.isLoading,
      onPressed: () => context.read<EventsCubit>().joinEvent(
            eventId: eventId.toString(),
          ),
      verticalPadding: 10,
    );
  }
}
