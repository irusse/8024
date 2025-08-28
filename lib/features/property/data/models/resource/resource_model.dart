import 'package:freezed_annotation/freezed_annotation.dart';
import '../../../../../core/config/app_config.dart';
import '../../../domain/entities/resource/resource_entity.dart';

part 'resource_model.g.dart';

@JsonSerializable()
class ResourceModel {
  final int id;
  final String name;
  final String? photo;
  final String category;
  final int propertyId;

  ResourceModel({
    required this.id,
    required this.name,
    required this.category,
    required this.propertyId,
    this.photo,
  });

  factory ResourceModel.fromJson(Map<String, dynamic> json) {
    final model = _$ResourceModelFromJson(json);
    final photo = model.photo;
    return ResourceModel(
      id: model.id,
      category: model.category,
      name: model.name,
      propertyId: model.propertyId,
      photo: (photo != null && photo.isNotEmpty)
          ? '${AppConfig.baseUrl}/files/$photo'
          : photo,
    );
  }

  Map<String, dynamic> toJson() => _$ResourceModelToJson(this);

  ResourceEntity toEntity() => ResourceEntity(
        id: id,
        name: name,
        photo: photo,
        category: category,
        propertyId: propertyId,
      );

  factory ResourceModel.fromEntity(ResourceEntity entity) => ResourceModel(
        id: entity.id,
        name: entity.name,
        photo: entity.photo,
        category: entity.category,
        propertyId: entity.propertyId,
      );
}
