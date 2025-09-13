import 'package:freezed_annotation/freezed_annotation.dart';

part 'user_location_entity.freezed.dart';

@freezed
abstract class UserLocationEntity with _$UserLocationEntity {
  const factory UserLocationEntity({
    required double lat,
    required double lng,
  }) = _UserLocationEntity;
}
