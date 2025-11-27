import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:neighbours/core/config/app_config.dart';
import 'package:neighbours/features/plan_b/domain/enitities/plan_b_details/plan_b_photo_entity.dart';

part 'plan_b_photo_model.g.dart';

@JsonSerializable()
class PlanBPhotoModel {
  final int id;
  final String url;

  PlanBPhotoModel({
    required this.id,
    required this.url,
  });

  factory PlanBPhotoModel.fromJson(
    Map<String, dynamic> json, {
    bool withFullPhotoPath = true,
  }) {
    final model = _$PlanBPhotoModelFromJson(json);
    
    final normalizedUrl = withFullPhotoPath && !model.url.startsWith('http')
        ? '${AppConfig.baseUrl}/files/${model.url}'
        : model.url;

    return PlanBPhotoModel(
      id: model.id,
      url: normalizedUrl,
    );
  }

  Map<String, dynamic> toJson() => _$PlanBPhotoModelToJson(this);

  PlanBPhotoEntity toEntity() => PlanBPhotoEntity(
        id: id,
        url: url,
      );
}
