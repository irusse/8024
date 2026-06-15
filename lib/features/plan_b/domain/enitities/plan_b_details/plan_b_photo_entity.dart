import 'package:freezed_annotation/freezed_annotation.dart';

part 'plan_b_photo_entity.freezed.dart';

@freezed
abstract class PlanBPhotoEntity with _$PlanBPhotoEntity {
  const factory PlanBPhotoEntity({
    required int id,
    required String url,
  }) = _PlanBPhotoEntity;
}
