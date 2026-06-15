import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:neighbours/core/config/app_config.dart';

import '../../../domain/entities/light_property/light_property_entity.dart';

part 'light_property_model.g.dart';

@JsonSerializable()
class LightPropertyModel {
  final int id;
  final String name;
  final String? picture;
  final String verificationStatus;

  LightPropertyModel({
    required this.id,
    required this.name,
    this.picture,
    required this.verificationStatus,
  });

  factory LightPropertyModel.fromJson(Map<String, dynamic> json) {
    final model = _$LightPropertyModelFromJson(json);
    final picture = model.picture;
    return LightPropertyModel(
      id: model.id,
      name: model.name,
      picture: (picture != null && picture.isNotEmpty)
          ? '${AppConfig.baseUrl}/files/$picture'
          : picture,
      verificationStatus: model.verificationStatus,
    );
  }

  Map<String, dynamic> toJson() => _$LightPropertyModelToJson(this);

  LightPropertyEntity toEntity() => LightPropertyEntity(
        id: id,
        name: name,
        picture: picture,
        verificationStatus: verificationStatus,
      );

  factory LightPropertyModel.fromEntity(LightPropertyEntity entity) =>
      LightPropertyModel(
        id: entity.id,
        name: entity.name,
        picture: entity.picture,
        verificationStatus: entity.verificationStatus,
      );
}
