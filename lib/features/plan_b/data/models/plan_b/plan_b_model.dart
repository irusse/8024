import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:neighbours/core/config/app_config.dart';
import 'package:neighbours/core/utils/date_time_converter.dart';
import 'package:neighbours/features/plan_b/domain/enitities/plan_b/plan_b_entity.dart';

part 'plan_b_model.g.dart';

@JsonSerializable()
class PlanBModel {
  final int id;
  final String name;
  final String? description;
  final String? address;
  final String? autonomyNotes;
  final String? financeInfo;
  final int categoryId;
  final double? latitude;
  final double? longitude;
  final double? price;
  final String status;
  final int createdBy;

  @DateTimeConverter()
  final DateTime createdAt;

  @DateTimeConverter()
  final DateTime updatedAt;

  /// Короткие URL из БД — приводим к полным
  final List<String> photos;

  PlanBModel({
    required this.id,
    required this.name,
    required this.description,
    required this.address,
    required this.autonomyNotes,
    required this.financeInfo,
    required this.categoryId,
    required this.latitude,
    required this.longitude,
    required this.price,
    required this.status,
    required this.createdBy,
    required this.createdAt,
    required this.updatedAt,
    required this.photos,
  });

  factory PlanBModel.fromJson(
      Map<String, dynamic> json, {
        bool withFullPhotoPath = true,
      }) {
    final model = _$PlanBModelFromJson(json);

    final normalizedPhotos = withFullPhotoPath
        ? model.photos
        .map((p) => '${AppConfig.baseUrl}/files/$p')
        .toList()
        : model.photos;

    return PlanBModel(
      id: model.id,
      name: model.name,
      description: model.description,
      address: model.address,
      autonomyNotes: model.autonomyNotes,
      financeInfo: model.financeInfo,
      categoryId: model.categoryId,
      latitude: model.latitude,
      longitude: model.longitude,
      price: model.price,
      status: model.status,
      createdBy: model.createdBy,
      createdAt: model.createdAt,
      updatedAt: model.updatedAt,
      photos: normalizedPhotos,
    );
  }

  Map<String, dynamic> toJson() => _$PlanBModelToJson(this);

  PlanBEntity toEntity() => PlanBEntity(
    id: id,
    name: name,
    description: description,
    address: address,
    autonomyNotes: autonomyNotes,
    financeInfo: financeInfo,
    categoryId: categoryId,
    latitude: latitude,
    longitude: longitude,
    price: price,
    status: status,
    createdBy: createdBy,
    createdAt: createdAt,
    updatedAt: updatedAt,
    photos: photos,
  );

  factory PlanBModel.fromEntity(PlanBEntity e) => PlanBModel(
    id: e.id,
    name: e.name,
    description: e.description,
    address: e.address,
    autonomyNotes: e.autonomyNotes,
    financeInfo: e.financeInfo,
    categoryId: e.categoryId,
    latitude: e.latitude,
    longitude: e.longitude,
    price: e.price,
    status: e.status,
    createdBy: e.createdBy,
    createdAt: e.createdAt,
    updatedAt: e.updatedAt,
    photos: e.photos,
  );
}
