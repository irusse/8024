import 'package:freezed_annotation/freezed_annotation.dart';

part 'unread_summary_entity.freezed.dart';

@freezed
abstract class UnreadSummaryEntity with _$UnreadSummaryEntity {
  const factory UnreadSummaryEntity({
    required Map<int, int> count,
    required int event,
    required int notification,
  }) = _UnreadSummaryEntity;

  factory UnreadSummaryEntity.initial() => const UnreadSummaryEntity(
        count: {},
        event: 0,
        notification: 0,
      );
}
