import 'package:freezed_annotation/freezed_annotation.dart';

part 'plan_b_category_short_entity.freezed.dart';

@freezed
abstract class PlanBCategoryShortEntity with _$PlanBCategoryShortEntity {
  const factory PlanBCategoryShortEntity({
    required int id,
    required String name,
  }) = _PlanBCategoryShortEntity;
}
