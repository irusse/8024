import 'package:neighbours/core/domain/entities/user_location/user_location_entity.dart';
import 'package:json_annotation/json_annotation.dart';

part 'user_location_model.g.dart';

@JsonSerializable()
class UserLocationModel {
  final double lat;
  final double lng;

  const UserLocationModel({
    required this.lat,
    required this.lng,
  });

  factory UserLocationModel.fromJson(Map<String, dynamic> json) {
    final model = _$UserLocationModelFromJson(json);
    return UserLocationModel(
      lat: model.lat,
      lng: model.lng,
    );
  }

  Map<String, dynamic> toJson() => _$UserLocationModelToJson(this);

  UserLocationEntity toEntity() => UserLocationEntity(
        lat: lat,
        lng: lng,
      );

  factory UserLocationModel.fromEntity(UserLocationEntity entity) =>
      UserLocationModel(
        lat: entity.lat,
        lng: entity.lng,
      );
}
