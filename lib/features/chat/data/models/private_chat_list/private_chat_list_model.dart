import 'package:json_annotation/json_annotation.dart';
import 'package:neighbours/core/data/models/participant/participant_model.dart';
import 'package:neighbours/core/utils/date_time_converter.dart';
import 'package:neighbours/features/chat/data/models/message/message_model.dart';
import 'package:neighbours/features/chat/domain/entities/private_chat_list/private_chat_list_entity.dart';

part 'private_chat_list_model.g.dart';

@JsonSerializable()
class PrivateChatListModel {
  final int id;
  final ParticipantModel user;
  final MessageModel lastMessage;
  final int unreadCount;
  @DateTimeConverter()
  final DateTime updatedAt;

  PrivateChatListModel({
    required this.id,
    required this.user,
    required this.lastMessage,
    required this.unreadCount,
    required this.updatedAt,
  });

  factory PrivateChatListModel.fromJson(Map<String, dynamic> json) =>
      _$PrivateChatListModelFromJson(json);

  Map<String, dynamic> toJson() => _$PrivateChatListModelToJson(this);

  PrivateChatListEntity toEntity() => PrivateChatListEntity(
        id: id,
        user: user.toEntity(),
        lastMessage: lastMessage.toEntity(),
        unreadCount: unreadCount,
        updatedAt: updatedAt.toLocal(),
      );

  factory PrivateChatListModel.fromEntity(PrivateChatListEntity entity) =>
      PrivateChatListModel(
        id: entity.id,
        user: ParticipantModel.fromEntity(entity.user),
        lastMessage: MessageModel.fromEntity(entity.lastMessage),
        unreadCount: entity.unreadCount,
        updatedAt: entity.updatedAt,
      );
}
