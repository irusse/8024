import 'package:freezed_annotation/freezed_annotation.dart';

part 'plan_b_map_entity.freezed.dart';

@freezed
abstract class PlanBMapEntity with _$PlanBMapEntity {
  const factory PlanBMapEntity({
    required int id,
    required String name,
    required double latitude,
    required double longitude,
    required String categoryName,
    String? icon,
    String? shortDescription,
    required String status,
  }) = _PlanBMapEntity;
}

