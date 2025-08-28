import 'package:flutter/material.dart';
import 'package:neighbours/core/domain/entities/event/event_entity.dart';
import 'package:neighbours/core/extensions/context_ext.dart';
import 'package:neighbours/features/home/presentation/widgets/event_info_dialog.dart';

class EventClusterList extends StatelessWidget {
  final List<FullEvent> events;

  const EventClusterList({super.key, required this.events});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 320,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: events.length,
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
        itemBuilder: (context, index) {
          final event = events[index];
          return Padding(
            padding: const EdgeInsets.only(right: 12),
            child: SizedBox(
                width: MediaQuery.of(context).size.width - 40,
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    color: context.color.background,
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: EventInfoDialog(
                    event: event,
                  ),
                )),
          );
        },
      ),
    );
  }
}
