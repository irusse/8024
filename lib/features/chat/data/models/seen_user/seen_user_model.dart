import 'package:json_annotation/json_annotation.dart';
import 'package:neighbours/core/data/models/participant/participant_model.dart';
import 'package:neighbours/core/utils/date_time_converter.dart';
import 'package:neighbours/features/chat/domain/entities/seen_user/seen_user_entity.dart';

part 'seen_user_model.g.dart';

@JsonSerializable()
class SeenUserModel {
  @DateTimeConverter()
  final DateTime seenAt;
  final ParticipantModel user;

  SeenUserModel({
    required this.seenAt,
    required this.user,
  });

  factory SeenUserModel.fromJson(Map<String, dynamic> json) =>
      _$SeenUserModelFromJson(json);

  Map<String, dynamic> toJson() => _$SeenUserModelToJson(this);

  SeenUserEntity toEntity() => SeenUserEntity(
        seenAt: seenAt.toLocal(),
        user: user.toEntity(),
      );

  factory SeenUserModel.fromEntity(SeenUserEntity entity) => SeenUserModel(
        seenAt: entity.seenAt,
        user: ParticipantModel.fromEntity(entity.user),
      );
}
