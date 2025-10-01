import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:neighbours/core/utils/int_key_converter.dart';
import 'package:neighbours/features/chat/domain/entities/community_unread_summary/community_unread_summary_entity.dart';

part 'community_unread_summary_model.g.dart';

@JsonSerializable()
class CommunityUnreadSummaryModel {
  @IntKeyMapConverter()
  final Map<int, int> count;

  @JsonKey(name: 'COMMUNITY')
  final int community;

  CommunityUnreadSummaryModel({
    required this.count,
    required this.community,
  });

  factory CommunityUnreadSummaryModel.fromJson(Map<String, dynamic> json) =>
      _$CommunityUnreadSummaryModelFromJson(json);

  Map<String, dynamic> toJson() => _$CommunityUnreadSummaryModelToJson(this);

  CommunityUnreadSummaryEntity toEntity() => CommunityUnreadSummaryEntity(
        count: count,
        community: community,
      );

  factory CommunityUnreadSummaryModel.fromEntity(CommunityUnreadSummaryEntity entity) =>
      CommunityUnreadSummaryModel(
        count: entity.count,
        community: entity.community,
      );
}