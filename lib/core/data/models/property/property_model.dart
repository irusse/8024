import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:neighbours/core/domain/entities/property/property_entity.dart';
import '../../../config/app_config.dart';
import '../../../utils/date_time_converter.dart';

part 'property_model.g.dart';

@JsonSerializable()
class PropertyModel {
  final int id;
  final int verificationCount;
  final String name;
  final String createdBy;
  final int createdById;
  final String category;
  final String verificationStatus;
  final double latitude;
  final double longitude;
  final String photo;
  final List<int> verifiedUserIds;
  @DateTimeConverter()
  final DateTime createdAt;

  @DateTimeConverter()
  final DateTime updatedAt;

  PropertyModel({
    required this.id,
    required this.name,
    required this.category,
    required this.createdBy,
    required this.createdById,
    required this.latitude,
    required this.verificationCount,
    required this.longitude,
    required this.verificationStatus,
    required this.createdAt,
    required this.updatedAt,
    required this.verifiedUserIds,
    required this.photo,
  });

  factory PropertyModel.fromJson(
    Map<String, dynamic> json, {
    bool withFullPhotoPath = true,
  }) {
    final model = _$PropertyModelFromJson(json);
    final rawPhoto = model.photo;

    final normalizedPhoto =
        withFullPhotoPath ? '${AppConfig.baseUrl}/files/$rawPhoto' : rawPhoto;

    return PropertyModel(
      id: model.id,
      name: model.name,
      category: model.category,
      verificationCount: model.verificationCount,
      latitude: model.latitude,
      createdBy: model.createdBy,
      createdById: model.createdById,
      verificationStatus: model.verificationStatus,
      longitude: model.longitude,
      createdAt: model.createdAt,
      updatedAt: model.updatedAt,
      verifiedUserIds: model.verifiedUserIds,
      photo: normalizedPhoto,
    );
  }

  Map<String, dynamic> toJson() => _$PropertyModelToJson(this);

  PropertyEntity toEntity() => PropertyEntity(
        id: id,
        name: name,
        category: category,
        createdBy: createdBy,
        createdById: createdById,
        verificationCount: verificationCount,
        verificationStatus: verificationStatus,
        latitude: latitude,
        longitude: longitude,
        photo: photo,
        createdAt: createdAt,
        updatedAt: updatedAt,
        verifiedUserIds: verifiedUserIds,
      );

  factory PropertyModel.fromEntity(PropertyEntity entity) => PropertyModel(
        id: entity.id,
        name: entity.name,
        category: entity.category,
        latitude: entity.latitude,
        createdBy: entity.createdBy,
        createdById: entity.createdById,
        verificationStatus: entity.verificationStatus,
        verificationCount: entity.verificationCount,
        longitude: entity.longitude,
        photo: entity.photo,
        createdAt: entity.createdAt,
        updatedAt: entity.updatedAt,
        verifiedUserIds: entity.verifiedUserIds,
      );
}
