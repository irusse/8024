import 'package:json_annotation/json_annotation.dart';
import 'package:neighbours/core/utils/date_time_converter.dart';
import 'package:neighbours/features/community/domain/entities/community/community_entity.dart';

part 'community_model.g.dart';

@JsonSerializable()
class CommunityModel {
  final int id;
  final String name;
  final String? description;
  final String status;
  final String joinCode;
  final String createdBy;
  @DateTimeConverter()
  final DateTime createdAt;

  CommunityModel({
    required this.id,
    required this.name,
    this.description,
    required this.status,
    required this.createdBy,
    required this.joinCode,
    required this.createdAt,
  });

  factory CommunityModel.fromJson(Map<String, dynamic> json) =>
      _$CommunityModelFromJson(json);

  Map<String, dynamic> toJson() => _$CommunityModelToJson(this);

  CommunityEntity toEntity() => CommunityEntity(
        id: id,
        name: name,
        description: description,
        status: status,
        joinCode: joinCode,
        createdBy: createdBy,
        createdAt: createdAt,
      );

  factory CommunityModel.fromEntity(CommunityEntity entity) => CommunityModel(
        id: entity.id,
        name: entity.name,
        description: entity.description,
        joinCode: entity.joinCode,
        status: entity.status,
        createdBy: entity.createdBy,
        createdAt: entity.createdAt,
      );
}
