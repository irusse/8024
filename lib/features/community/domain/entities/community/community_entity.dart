import 'package:freezed_annotation/freezed_annotation.dart';

part 'community_entity.freezed.dart';

@freezed
abstract class CommunityEntity with _$CommunityEntity {
  const factory CommunityEntity({
    required int id,
    required String name,
    required String status,
    required String joinCode,
    required String createdBy,
    required DateTime createdAt,
    String? description,
  }) = _CommunityEntity;
}
