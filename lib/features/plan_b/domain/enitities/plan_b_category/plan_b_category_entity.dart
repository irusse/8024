import 'package:freezed_annotation/freezed_annotation.dart';

part 'plan_b_category_entity.freezed.dart';

@freezed
abstract class PlanBCategoryEntity with _$PlanBCategoryEntity {
  const factory PlanBCategoryEntity({
    required int id,
    required String name,
    String? description,
    String? icon,
    required int displayOrder,
    required DateTime createdAt,
    required DateTime updatedAt,
  }) = _PlanBCategoryEntity;
}
