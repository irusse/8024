import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:neighbours/core/mixins/has_name_mixin.dart';
import 'package:neighbours/features/community/domain/entities/community/community_entity.dart';

part 'user_entity.freezed.dart';

@freezed
abstract class UserEntity with _$UserEntity implements HasName {
  const factory UserEntity({
    required int id,
    required String firstName,
    required String phone,
    required List<CommunityEntity> communities,
    String? lastName,
    String? email,
    String? avatar,
    String? gender,
    DateTime? birthDate,
    String? address,
    double? latitude,
    double? longitude,
    DateTime? deletionScheduledAt,
  }) = _UserEntity;
}
