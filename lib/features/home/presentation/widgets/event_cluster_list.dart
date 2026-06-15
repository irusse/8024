import 'package:flutter/material.dart';
import 'package:neighbours/core/extensions/context_ext.dart';
import 'package:neighbours/features/event/domain/entities/event/event_entity.dart';
import 'package:neighbours/features/home/presentation/widgets/event_info_dialog.dart';

class EventClusterList extends StatelessWidget {
  final List<EventEntity> events;

  const EventClusterList({super.key, required this.events});

  @override
  Widget build(BuildContext context) {

    final screenWidth = MediaQuery
        .of(context)
        .size
        .width;
    return SizedBox(
      height: 320,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: events.length,
        padding: const EdgeInsets.symmetric(horizontal: 8),
        itemBuilder: (context, index) {
          final event = events[index];
          return Container(
            margin: const EdgeInsets.only(right: 12),
            width: screenWidth - 32,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              color: context.color.background,
            ),
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: EventInfoDialog(
              event: event,
            ),
          );
        },
      ),
    );
  }
}
