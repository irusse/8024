import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:neighbours/core/utils/date_time_converter.dart';
import 'package:neighbours/features/plan_b/data/models/plan_b_details/plan_b_category_short_model.dart';
import 'package:neighbours/features/plan_b/data/models/plan_b_details/plan_b_parameter_model.dart';
import 'package:neighbours/features/plan_b/data/models/plan_b_details/plan_b_photo_model.dart';
import 'package:neighbours/features/plan_b/domain/enitities/plan_b_details/plan_b_details_entity.dart';

part 'plan_b_details_model.g.dart';

@JsonSerializable()
class PlanBDetailsModel {
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

  final PlanBCategoryShortModel category;
  final List<PlanBPhotoModel> photos;
  final List<PlanBParameterModel> parameters;

  PlanBDetailsModel({
    required this.id,
    required this.name,
    this.description,
    this.address,
    this.autonomyNotes,
    this.financeInfo,
    required this.categoryId,
    this.latitude,
    this.longitude,
    this.price,
    required this.status,
    required this.createdBy,
    required this.createdAt,
    required this.updatedAt,
    required this.category,
    required this.photos,
    required this.parameters,
  });

  factory PlanBDetailsModel.fromJson(
    Map<String, dynamic> json, {
    bool withFullPhotoPath = true,
  }) {
    final rawModel = _$PlanBDetailsModelFromJson(json);

    // Обрабатываем фотографии с полными путями
    final processedPhotos = (json['photos'] as List<dynamic>?)
            ?.map((p) => PlanBPhotoModel.fromJson(
                  p as Map<String, dynamic>,
                  withFullPhotoPath: withFullPhotoPath,
                ))
            .toList() ??
        [];

    return PlanBDetailsModel(
      id: rawModel.id,
      name: rawModel.name,
      description: rawModel.description,
      address: rawModel.address,
      autonomyNotes: rawModel.autonomyNotes,
      financeInfo: rawModel.financeInfo,
      categoryId: rawModel.categoryId,
      latitude: rawModel.latitude,
      longitude: rawModel.longitude,
      price: rawModel.price,
      status: rawModel.status,
      createdBy: rawModel.createdBy,
      createdAt: rawModel.createdAt,
      updatedAt: rawModel.updatedAt,
      category: rawModel.category,
      photos: processedPhotos,
      parameters: rawModel.parameters,
    );
  }

  Map<String, dynamic> toJson() => _$PlanBDetailsModelToJson(this);

  PlanBDetailsEntity toEntity() => PlanBDetailsEntity(
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
        category: category.toEntity(),
        photos: photos.map((p) => p.toEntity()).toList(),
        parameters: parameters.map((p) => p.toEntity()).toList(),
      );
}
