import 'package:freezed_annotation/freezed_annotation.dart';

part 'light_community_entity.freezed.dart';

@freezed
abstract class LightCommunityEntity with _$LightCommunityEntity {
  const factory LightCommunityEntity({
    required int id,
    required String name,
  }) = _LightCommunityEntity;
}
