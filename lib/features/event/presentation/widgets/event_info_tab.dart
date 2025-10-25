import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:neighbours/core/components/custom_gap.dart';
import 'package:neighbours/core/constants/ui_constants.dart';
import 'package:neighbours/core/cubits/user/user_cubit.dart';
import 'package:neighbours/core/extensions/context_ext.dart';
import 'package:neighbours/core/extensions/full_name_ext.dart';
import 'package:neighbours/features/event/domain/entities/event/event_entity.dart';
import 'package:neighbours/features/event/presentation/widgets/date_time_row.dart';
import 'package:neighbours/features/event/presentation/widgets/default_divider.dart';
import 'package:neighbours/features/event/presentation/widgets/location_address_view.dart';
import 'package:neighbours/features/event/presentation/widgets/poll_results.dart';
import '../../../../core/components/map_preview.dart';

class EventInfoTab extends StatefulWidget {
  final EventEntity event;

  const EventInfoTab({super.key, required this.event});

  @override
  State<EventInfoTab> createState() => _EventInfoTabState();
}

class _EventInfoTabState extends State<EventInfoTab>
    with AutomaticKeepAliveClientMixin {
  @override
  Widget build(BuildContext context) {
    final userId = context.read<UserCubit>().state.user.id;
    super.build(context);
    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minHeight: constraints.maxHeight,
            ),
            child: IntrinsicHeight(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _description(context),
                  const DefaultDivider(),
                  _creatorInfo(context, widget.event),
                  const DefaultDivider(),
                  if (widget.event.eventDateTime != null)
                    DateTimeRow(dateTime: widget.event.eventDateTime!),
                  const VerticalGap(16),
                  if (widget.event.votingQuestion != null)
                    PollResults(
                      isCompleted: widget.event.isCompleted,
                      eventId: widget.event.id,
                      canVote: widget.event.isParticipant(userId) ||
                          widget.event.isCreator(userId),
                    ),
                  const Spacer(), // теперь Spacer работает корректно!
                  _bottomMapSection(context), // карта внизу
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _description(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: UIConstants.defaultHorizontalPadding,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const VerticalGap(8),
          Text(
            'Описание',
            style:
                context.text.titleSmall.copyWith(fontWeight: FontWeight.w500),
          ),
          const VerticalGap(8),
          Text(
            widget.event.description.isNotEmpty
                ? widget.event.description
                : 'Описание отсутствует',
            style: context.text.bodyLarge,
          ),
          const VerticalGap(8),
        ],
      ),
    );
  }

  Widget _creatorInfo(BuildContext context, EventEntity event) {
    final fullName = event.creator.fullName;
    final address = event.creator.address ?? '';
    return Padding(
      padding: const EdgeInsets.symmetric(
          horizontal: UIConstants.defaultHorizontalPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const VerticalGap(8),
          Text(
            'Организатор',
            style:
                context.text.titleSmall.copyWith(fontWeight: FontWeight.w500),
          ),
          const VerticalGap(8),
          Text(
            "$fullName\n$address",
            style: context.text.bodyLarge.copyWith(
                fontWeight: FontWeight.w500, color: context.color.primary),
          ),
          const VerticalGap(8),
        ],
      ),
    );
  }

  Widget _bottomMapSection(BuildContext context) {
    return Container(
      height: 192,
      padding: const EdgeInsets.all(12),
      width: double.infinity,
      decoration: BoxDecoration(
        color: context.color.secondary,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
      ),
      alignment: Alignment.center,
      child: Column(
        children: [
          LocationAddressView(
            latitude: widget.event.latitude,
            longitude: widget.event.longitude,
          ),
          const VerticalGap(8),
          Expanded(
            child: MapPreview(
              latitude: widget.event.latitude,
              longitude: widget.event.longitude,
              radius: 12,
            ),
          ),
        ],
      ),
    );
  }

  @override
  bool get wantKeepAlive => true;
}
