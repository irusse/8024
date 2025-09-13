import 'package:json_annotation/json_annotation.dart';
import 'package:neighbours/core/data/models/participant/participant_model.dart';
import 'package:neighbours/core/utils/date_time_converter.dart';
import 'package:neighbours/features/chat/domain/entities/message/message_entity.dart';

part 'message_model.g.dart';

@JsonSerializable()
class MessageModel {
  final int id;
  final String text;
  @DateTimeConverter()
  final DateTime createdAt;
  @DateTimeConverter()
  final DateTime updatedAt;
  final int eventId;
  final int userId;
  final ParticipantModel user;

  MessageModel({
    required this.id,
    required this.text,
    required this.createdAt,
    required this.updatedAt,
    required this.eventId,
    required this.userId,
    required this.user,
  });

  factory MessageModel.fromJson(Map<String, dynamic> json) =>
      _$MessageModelFromJson(json);

  Map<String, dynamic> toJson() => _$MessageModelToJson(this);

  MessageEntity toEntity() => MessageEntity(
        id: id,
        text: text,
        createdAt: createdAt.toLocal(),
        updatedAt: updatedAt,
        eventId: eventId,
        userId: userId,
        user: user.toEntity(),
      );

  factory MessageModel.fromEntity(MessageEntity entity) => MessageModel(
        id: entity.id,
        text: entity.text,
        createdAt: entity.createdAt,
        updatedAt: entity.updatedAt,
        eventId: entity.eventId,
        userId: entity.userId,
        user: ParticipantModel.fromEntity(entity.user),
      );
}
