import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:neighbours/core/config/app_config.dart';
import 'package:neighbours/core/domain/entities/user/user_entity.dart';
import 'package:neighbours/core/utils/date_time_converter.dart';
import 'package:neighbours/features/community/data/models/communtiy/community_model.dart';

part 'user_model.g.dart';

@JsonSerializable()
class UserModel {
  final int id;
  final String? firstName;
  final String? lastName;
  final String? email;
  final String phone;
  final List<CommunityModel> communities;
  final String? avatar;
  final String? gender;
  @DateTimeConverter()
  final DateTime? birthDate;
  final double? latitude;
  final double? longitude;
  final String? address;
  @NullableDateTimeConverter()
  final DateTime? deletionScheduledAt;

  UserModel({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.phone,
    this.avatar,
    this.gender,
    this.birthDate,
    required this.latitude,
    required this.longitude,
    this.address,
    required this.communities,
    this.deletionScheduledAt,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    final model = _$UserModelFromJson(json);
    final avatar = model.avatar;
    return UserModel(
      id: model.id,
      firstName: model.firstName,
      lastName: model.lastName,
      email: model.email,
      phone: model.phone,
      avatar: (avatar != null && avatar.isNotEmpty)
          ? '${AppConfig.baseUrl}/files/$avatar'
          : avatar,
      gender: model.gender,
      birthDate: model.birthDate,
      latitude: model.latitude,
      longitude: model.longitude,
      address: model.address,
      communities: model.communities,
      deletionScheduledAt: model.deletionScheduledAt,
    );
  }

  Map<String, dynamic> toJson() => _$UserModelToJson(this);

  UserEntity toEntity() => UserEntity(
        id: id,
        firstName: firstName ?? '',
        lastName: lastName,
        email: email,
        phone: phone,
        avatar: avatar,
        gender: gender,
        birthDate: birthDate,
        latitude: latitude,
        longitude: longitude,
        address: address,
        communities: communities.map((c) => c.toEntity()).toList(),
        deletionScheduledAt: deletionScheduledAt,
      );

  factory UserModel.fromEntity(UserEntity entity) => UserModel(
        id: entity.id,
        email: entity.email,
        lastName: entity.lastName,
        firstName: entity.firstName,
        phone: entity.phone,
        avatar: entity.avatar,
        gender: entity.gender,
        birthDate: entity.birthDate,
        latitude: entity.latitude,
        longitude: entity.longitude,
        address: entity.address,
        communities: entity.communities
            .map((c) => CommunityModel.fromEntity(c))
            .toList(),
        deletionScheduledAt: entity.deletionScheduledAt,
      );
}
