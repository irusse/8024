import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:neighbours/features/plan_b/domain/enitities/plan_b_details/plan_b_category_short_entity.dart';

part 'plan_b_category_short_model.g.dart';

@JsonSerializable()
class PlanBCategoryShortModel {
  final int id;
  final String name;

  PlanBCategoryShortModel({
    required this.id,
    required this.name,
  });

  factory PlanBCategoryShortModel.fromJson(Map<String, dynamic> json) =>
      _$PlanBCategoryShortModelFromJson(json);

  Map<String, dynamic> toJson() => _$PlanBCategoryShortModelToJson(this);

  PlanBCategoryShortEntity toEntity() => PlanBCategoryShortEntity(
        id: id,
        name: name,
      );
}
