import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:neighbours/core/domain/entities/event/participant_entity.dart';
import '../../../config/app_config.dart';

part 'participant_model.g.dart';

@JsonSerializable()
class ParticipantModel {
  final int id;
  final String firstName;
  final String? address;
  final String? lastName;
  final String? avatar;

  const ParticipantModel({
    required this.id,
    required this.firstName,
    this.address,
    this.lastName,
    this.avatar,
  });

  factory ParticipantModel.fromJson(Map<String, dynamic> json) {
    final model = _$ParticipantModelFromJson(json);
    final avatar = model.avatar;
    return ParticipantModel(
      id: model.id,
      firstName: model.firstName,
      address: model.address,
      lastName: model.lastName,
      avatar: (avatar != null && avatar.isNotEmpty)
          ? '${AppConfig.baseUrl}/files/$avatar'
          : avatar,
    );
  }

  Map<String, dynamic> toJson() => _$ParticipantModelToJson(this);

  ParticipantEntity toEntity() => ParticipantEntity(
      id: id,
      firstName: firstName,
      lastName: lastName,
      avatar: avatar,
      address: address ?? 'Не определен');

  factory ParticipantModel.fromEntity(ParticipantEntity entity) =>
      ParticipantModel(
          id: entity.id,
          firstName: entity.firstName,
          lastName: entity.lastName,
          avatar: entity.avatar,
          address: entity.address);
}
