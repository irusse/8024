import 'package:freezed_annotation/freezed_annotation.dart';

import '../property/property_entity.dart';

part 'user_verified_property_entity.freezed.dart';


@freezed
abstract class UserVerifiedPropertyEntity with _$UserVerifiedPropertyEntity {
  const factory UserVerifiedPropertyEntity({
    required PropertyEntity property,
    required DateTime verifiedAt,
  }) = _UserVerifiedPropertyEntity;
}
