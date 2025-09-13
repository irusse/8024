import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:neighbours/core/extensions/context_ext.dart';
import 'package:neighbours/features/event/presentation/cubits/events/events_cubit.dart';

import '../../../../core/components/custom_alert_dialog.dart';
import '../../../../core/components/primary_button.dart';
import '../../../../core/state/api_state.dart';

class ParticipateButton extends StatelessWidget {
  final int eventId;
  final bool isCreator;
  final bool isParticipant;

  final ApiState joinState;
  final ApiState leaveState;

  const ParticipateButton({
    super.key,
    required this.eventId,
    required this.isCreator,
    required this.isParticipant,
    required this.joinState,
    required this.leaveState,
  });

  Future<void> _onLeaveClick(BuildContext context) async {
    final leaveConfirm = await showDialog<bool>(
      context: context,
      builder: (context) => CustomAlertDialog(
        title: 'Выйти из мероприятия?',
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

  @override
  Widget build(BuildContext context) {
    if (isCreator) {
      return const SizedBox.shrink();
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
