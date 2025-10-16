import 'package:json_annotation/json_annotation.dart';
import 'package:neighbours/core/data/models/participant/participant_model.dart';
import 'package:neighbours/core/utils/date_time_converter.dart';
import 'package:neighbours/features/chat/domain/entities/message/message_entity.dart';
import 'package:neighbours/features/chat/data/models/seen_user/seen_user_model.dart';

part 'message_model.g.dart';

@JsonSerializable()
class MessageModel {
  final int id;
  final String text;
  @DateTimeConverter()
  final DateTime createdAt;
  @DateTimeConverter()
  final DateTime updatedAt;
  final int? eventId;
  final int? communityId;
  final int? conversationId;
  final int userId;
  final ParticipantModel user;
  final bool? isRead;
  final List<SeenUserModel>? seenUsers;
  final bool? isNewConversation;
  final ParticipantModel? receiver;

  MessageModel({
    required this.id,
    required this.text,
    required this.createdAt,
    required this.updatedAt,
    this.eventId,
    this.communityId,
    this.conversationId,
    required this.userId,
    required this.user,
    this.isRead,
    this.seenUsers,
    this.isNewConversation,
    this.receiver,
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
        communityId: communityId,
        conversationId: conversationId,
        userId: userId,
        user: user.toEntity(),
        isRead: isRead,
        seenUsers: seenUsers?.map((seenUser) => seenUser.toEntity()).toList(),
        isNewConversation: isNewConversation,
        receiver: receiver?.toEntity(),
      );

  factory MessageModel.fromEntity(MessageEntity entity) => MessageModel(
        id: entity.id,
        text: entity.text,
        createdAt: entity.createdAt,
        updatedAt: entity.updatedAt,
        eventId: entity.eventId,
        communityId: entity.communityId,
        conversationId: entity.conversationId,
        userId: entity.userId,
        user: ParticipantModel.fromEntity(entity.user),
        isRead: entity.isRead,
        seenUsers: entity.seenUsers
            ?.map((seenUser) => SeenUserModel.fromEntity(seenUser))
            .toList(),
        isNewConversation: entity.isNewConversation,
        receiver: entity.receiver != null 
            ? ParticipantModel.fromEntity(entity.receiver!) 
            : null,
      );
}
