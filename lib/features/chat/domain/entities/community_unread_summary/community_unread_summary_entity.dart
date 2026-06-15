import 'package:freezed_annotation/freezed_annotation.dart';

part 'community_unread_summary_entity.freezed.dart';

@freezed
abstract class CommunityUnreadSummaryEntity with _$CommunityUnreadSummaryEntity {
  const factory CommunityUnreadSummaryEntity({
    required Map<int, int> count,
    required int community,
  }) = _CommunityUnreadSummaryEntity;

  factory CommunityUnreadSummaryEntity.initial() => const CommunityUnreadSummaryEntity(
        count: {},
        community: 0,
      );
}