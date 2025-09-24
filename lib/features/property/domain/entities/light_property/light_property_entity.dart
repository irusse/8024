import 'package:freezed_annotation/freezed_annotation.dart';

part 'light_property_entity.freezed.dart';

@freezed
abstract class LightPropertyEntity with _$LightPropertyEntity {
  const factory LightPropertyEntity({
    required int id,
    required String name,
    String? picture,
    required String verificationStatus,
  }) = _LightPropertyEntity;
}
