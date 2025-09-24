import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:neighbours/core/mixins/has_name_mixin.dart';
import 'package:neighbours/features/community/domain/entities/light_community/light_community_entity.dart';

part 'other_user_entity.freezed.dart';

@freezed
abstract class OtherUserEntity with _$OtherUserEntity implements HasName {
  const factory OtherUserEntity({
    required int id,
    required String firstName,
    String? lastName,
    String? email,
    String? avatar,
    String? gender,
    DateTime? birthDate,
    required bool isVerified,
    int? blockingId,
    required List<LightCommunityEntity> communities,
    required DateTime createdAt,
  }) = _OtherUserEntity;
}
