import 'package:freezed_annotation/freezed_annotation.dart';
import '../../../domain/entities/light_community/light_community_entity.dart';

part 'light_community_model.g.dart';

@JsonSerializable()
class LightCommunityModel {
  final int id;
  final String name;

  LightCommunityModel({
    required this.id,
    required this.name,
  });

  factory LightCommunityModel.fromJson(Map<String, dynamic> json) =>
      _$LightCommunityModelFromJson(json);

  Map<String, dynamic> toJson() => _$LightCommunityModelToJson(this);

  LightCommunityEntity toEntity() => LightCommunityEntity(
        id: id,
        name: name,
      );

  factory LightCommunityModel.fromEntity(LightCommunityEntity entity) =>
      LightCommunityModel(
        id: entity.id,
        name: entity.name,
      );
}
