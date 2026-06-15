import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:neighbours/core/domain/entities/participant/participant_entity.dart';
import 'package:neighbours/features/chat/domain/entities/message/message_entity.dart';

part 'private_chat_list_entity.freezed.dart';

@freezed
abstract class PrivateChatListEntity with _$PrivateChatListEntity {
  const factory PrivateChatListEntity({
    required int id,
    required ParticipantEntity user,
    required MessageEntity lastMessage,
    required int unreadCount,
    required DateTime updatedAt,
  }) = _PrivateChatListEntity;
}
