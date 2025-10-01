import 'package:freezed_annotation/freezed_annotation.dart';

part 'event_unread_summary_entity.freezed.dart';

@freezed
abstract class EventUnreadSummaryEntity with _$EventUnreadSummaryEntity {
  const factory EventUnreadSummaryEntity({
    required Map<int, int> count,
    required int event,
    required int notification,
  }) = _EventUnreadSummaryEntity;

  factory EventUnreadSummaryEntity.initial() => const EventUnreadSummaryEntity(
        count: {},
        event: 0,
        notification: 0,
      );
}