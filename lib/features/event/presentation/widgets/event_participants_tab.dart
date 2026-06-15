import 'package:flutter/material.dart';
import 'package:neighbours/core/components/custom_gap.dart';
import 'package:neighbours/core/components/participant_item.dart';
import 'package:neighbours/core/domain/entities/participant/participant_entity.dart';
import 'package:neighbours/core/extensions/context_ext.dart';
import 'package:neighbours/core/extensions/full_name_ext.dart';

class EventParticipantsTab extends StatefulWidget {
  final List<ParticipantEntity> participants;

  const EventParticipantsTab({super.key, required this.participants});

  @override
  State<EventParticipantsTab> createState() => _EventParticipantsTabState();
}

class _EventParticipantsTabState extends State<EventParticipantsTab>
    with AutomaticKeepAliveClientMixin {
  @override
  Widget build(BuildContext context) {
    super.build(context);
    if (widget.participants.isEmpty) {
      return const Center(
        child: Text(
          "Участники отсутствуют",
          style: TextStyle(color: Colors.white),
        ),
      );
    }
    return ListView.builder(
      itemCount: widget.participants.length,
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      itemBuilder: (context, index) {
        final participant = widget.participants[index];
        return index == 0
            ? Row(
                children: [
                  Expanded(
                      child: ParticipantItem(
                    id: participant.id,
                    fullName: participant.fullName,
                    avatar: participant.avatar,
                  )),
                  const HorizontalGap(8),
                  Text(
                    'основатель',
                    style: context.text.bodyMedium
                        .copyWith(color: context.color.secondaryText),
                  )
                ],
              )
            : ParticipantItem(
                id: participant.id,
                fullName: participant.fullName,
                avatar: participant.avatar,
              );
      },
    );
  }

  @override
  bool get wantKeepAlive => true;
}
