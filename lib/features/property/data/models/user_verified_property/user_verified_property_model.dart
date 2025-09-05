import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:neighbours/features/property/data/models/property/property_model.dart';
import 'package:neighbours/features/property/domain/entities/user_verified_property/user_verified_property_entity.dart';

part 'user_verified_property_model.g.dart';

@JsonSerializable()
class UserVerifiedPropertyModel {
  final PropertyModel property;
  final DateTime verifiedAt;

  const UserVerifiedPropertyModel({
    required this.property,
    required this.verifiedAt,
  });

  factory UserVerifiedPropertyModel.fromJson(Map<String, dynamic> json) =>
      _$UserVerifiedPropertyModelFromJson(json);

  Map<String, dynamic> toJson() => _$UserVerifiedPropertyModelToJson(this);

  factory UserVerifiedPropertyModel.fromEntity(
          UserVerifiedPropertyEntity entity) =>
      UserVerifiedPropertyModel(
        property: PropertyModel.fromEntity(entity.property),
        verifiedAt: entity.verifiedAt,
      );

  UserVerifiedPropertyEntity toEntity() => UserVerifiedPropertyEntity(
        property: property.toEntity(),
        verifiedAt: verifiedAt,
      );
}
