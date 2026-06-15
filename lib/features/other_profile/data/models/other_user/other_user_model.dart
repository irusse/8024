import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:neighbours/core/config/app_config.dart';
import 'package:neighbours/core/utils/date_time_converter.dart';
import '../../../../community/data/models/light_community/light_community_model.dart';
import '../../../domain/entities/other_user/other_user_entity.dart';

part 'other_user_model.g.dart';

@JsonSerializable()
class OtherUserModel {
  final int id;
  final String? firstName;
  final String? lastName;
  final String? email;
  final String? avatar;
  final String? gender;
  @DateTimeConverter()
  final DateTime? birthDate;
  final bool isVerified;
  final int? blockingId;
  @DateTimeConverter()
  final DateTime createdAt;
  final List<LightCommunityModel> communities;

  OtherUserModel({
    required this.id,
    this.firstName,
    this.lastName,
    this.email,
    this.avatar,
    this.gender,
    this.birthDate,
    required this.isVerified,
    this.blockingId,
    required this.createdAt,
    required this.communities,
  });

  factory OtherUserModel.fromJson(Map<String, dynamic> json) {
    final model = _$OtherUserModelFromJson(json);
    final avatar = model.avatar;
    return OtherUserModel(
      id: model.id,
      firstName: model.firstName,
      lastName: model.lastName,
      email: model.email,
      avatar: (avatar != null && avatar.isNotEmpty)
          ? '${AppConfig.baseUrl}/files/$avatar'
          : avatar,
      gender: model.gender,
      birthDate: model.birthDate,
      isVerified: model.isVerified,
      blockingId: model.blockingId,
      createdAt: model.createdAt,
      communities: model.communities,
    );
  }

  Map<String, dynamic> toJson() => _$OtherUserModelToJson(this);

  OtherUserEntity toEntity() => OtherUserEntity(
        id: id,
        firstName: firstName ?? '',
        lastName: lastName,
        email: email,
        avatar: avatar,
        gender: gender,
        birthDate: birthDate,
        isVerified: isVerified,
        blockingId: blockingId,
        createdAt: createdAt,
        communities: communities.map((c) => c.toEntity()).toList(),
      );

  factory OtherUserModel.fromEntity(OtherUserEntity entity) => OtherUserModel(
        id: entity.id,
        firstName: entity.firstName,
        lastName: entity.lastName,
        email: entity.email,
        avatar: entity.avatar,
        gender: entity.gender,
        birthDate: entity.birthDate,
        isVerified: entity.isVerified,
        blockingId: entity.blockingId,
        createdAt: entity.createdAt,
        communities: entity.communities
            .map((c) => LightCommunityModel.fromEntity(c))
            .toList(),
      );
}
