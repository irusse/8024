import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:neighbours/core/components/primary_button.dart';
import 'package:neighbours/core/domain/entities/event/event_entity.dart';
import 'package:neighbours/core/router/app_routes.dart';
import 'package:neighbours/features/community/presentation/widgets/event_card.dart';

import '../../../../core/components/custom_gap.dart';
import '../../../event/presentation/widgets/location_address_view.dart';

class EventInfoDialog extends StatelessWidget {
  final EventEntity event;

  const EventInfoDialog({super.key, required this.event});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const VerticalGap(8),
        EventCard(event: event),
        const VerticalGap(8),
        LocationAddressView(
          latitude: event.latitude,
          longitude: event.longitude,
          maxLines: 1,
        ),
        const VerticalGap(16),
        PrimaryButton(
          text: 'Подробнее',
          onPressed: () {
            context.pop();
            context.push(AppRouteBuilder.eventDetails(event.id));
          },
          verticalPadding: 10,
        ),
        const VerticalGap(16)
      ],
    );
  }
}
