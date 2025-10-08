import 'package:json_annotation/json_annotation.dart';
import 'package:neighbours/core/data/models/participant/participant_model.dart';
import 'package:neighbours/core/utils/date_time_converter.dart';
import 'package:neighbours/features/chat/data/models/message/message_model.dart';
import 'package:neighbours/features/chat/domain/entities/message_read/message_read_entity.dart';

part 'message_read_model.g.dart';

@JsonSerializable()
class MessageReadModel {
  @DateTimeConverter()
  final DateTime seenAt;
  final ParticipantModel user;
  final MessageModel message;

  MessageReadModel({
    required this.seenAt,
    required this.user,
    required this.message,
  });

  factory MessageReadModel.fromJson(Map<String, dynamic> json) =>
      _$MessageReadModelFromJson(json);

  Map<String, dynamic> toJson() => _$MessageReadModelToJson(this);

  MessageReadEntity toEntity() => MessageReadEntity(
        seenAt: seenAt.toLocal(),
        user: user.toEntity(),
        message: message.toEntity(),
      );

  factory MessageReadModel.fromEntity(MessageReadEntity entity) =>
      MessageReadModel(
        seenAt: entity.seenAt,
        user: ParticipantModel.fromEntity(entity.user),
        message: MessageModel.fromEntity(entity.message),
      );
}
