import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:neighbours/core/config/app_config.dart';
import 'package:neighbours/features/plan_b/domain/enitities/plan_b_map/plan_b_map_entity.dart';

part 'plan_b_map_model.g.dart';

@JsonSerializable()
class PlanBMapModel {
  final int id;
  final String name;
  final double latitude;
  final double longitude;
  final String categoryName;
  final String? icon;
  final String? shortDescription;
  final String status;
  final double price;

  PlanBMapModel({
    required this.id,
    required this.name,
    required this.latitude,
    required this.longitude,
    required this.categoryName,
    required this.icon,
    required this.shortDescription,
    required this.status,
    required this.price,
  });

  factory PlanBMapModel.fromJson(
    Map<String, dynamic> json, {
    bool withFullIconPath = true,
  }) {
    final model = _$PlanBMapModelFromJson(json);

    final normalizedIcon = model.icon == null
        ? null
        : (withFullIconPath && !model.icon!.startsWith('http')
            ? '${AppConfig.baseUrl}/files/${model.icon}'
            : model.icon);

    return PlanBMapModel(
      id: model.id,
      name: model.name,
      latitude: model.latitude,
      longitude: model.longitude,
      categoryName: model.categoryName,
      icon: normalizedIcon,
      shortDescription: model.shortDescription,
      status: model.status,
      price: model.price,
    );
  }

  Map<String, dynamic> toJson() => _$PlanBMapModelToJson(this);

  PlanBMapEntity toEntity() => PlanBMapEntity(
        id: id,
        name: name,
        latitude: latitude,
        longitude: longitude,
        categoryName: categoryName,
        icon: icon,
        shortDescription: shortDescription,
        status: status,
        price: price,
      );

  factory PlanBMapModel.fromEntity(PlanBMapEntity e) => PlanBMapModel(
        id: e.id,
        name: e.name,
        latitude: e.latitude,
        longitude: e.longitude,
        categoryName: e.categoryName,
        icon: e.icon,
        shortDescription: e.shortDescription,
        status: e.status,
        price: e.price,
      );
}

