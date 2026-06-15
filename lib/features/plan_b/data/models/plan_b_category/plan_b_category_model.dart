import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:neighbours/core/config/app_config.dart';
import 'package:neighbours/core/utils/date_time_converter.dart';
import 'package:neighbours/features/plan_b/domain/enitities/plan_b_category/plan_b_category_entity.dart';

part 'plan_b_category_model.g.dart';

@JsonSerializable()
class PlanBCategoryModel {
  final int id;
  final String name;
  final String? description;
  final String? icon;
  final int displayOrder;

  @DateTimeConverter()
  final DateTime createdAt;

  @DateTimeConverter()
  final DateTime updatedAt;

  PlanBCategoryModel({
    required this.id,
    required this.name,
    required this.description,
    required this.icon,
    required this.displayOrder,
    required this.createdAt,
    required this.updatedAt,
  });

  factory PlanBCategoryModel.fromJson(
      Map<String, dynamic> json, {
        bool withFullIconPath = true,
      }) {
    final model = _$PlanBCategoryModelFromJson(json);

    final normalizedIcon = model.icon == null
        ? null
        : (withFullIconPath
        ? '${AppConfig.baseUrl}/files/${model.icon}'
        : model.icon);

    return PlanBCategoryModel(
      id: model.id,
      name: model.name,
      description: model.description,
      icon: normalizedIcon,
      displayOrder: model.displayOrder,
      createdAt: model.createdAt,
      updatedAt: model.updatedAt,
    );
  }

  Map<String, dynamic> toJson() => _$PlanBCategoryModelToJson(this);

  PlanBCategoryEntity toEntity() => PlanBCategoryEntity(
    id: id,
    name: name,
    description: description,
    icon: icon,
    displayOrder: displayOrder,
    createdAt: createdAt,
    updatedAt: updatedAt,
  );

  factory PlanBCategoryModel.fromEntity(PlanBCategoryEntity e) =>
      PlanBCategoryModel(
        id: e.id,
        name: e.name,
        description: e.description,
        icon: e.icon,
        displayOrder: e.displayOrder,
        createdAt: e.createdAt,
        updatedAt: e.updatedAt,
      );
}
