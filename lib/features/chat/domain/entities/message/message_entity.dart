import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:neighbours/core/domain/entities/participant/participant_entity.dart';
import 'package:neighbours/features/chat/domain/entities/seen_user/seen_user_entity.dart';

part 'message_entity.freezed.dart';

@freezed
abstract class MessageEntity with _$MessageEntity {
  const factory MessageEntity({
    required int id,
    required String text,
    required DateTime createdAt,
    required DateTime updatedAt,
    int? eventId,
    int? communityId,
    int? conversationId,
    required int userId,
    required ParticipantEntity user,
    bool? isRead,
    List<SeenUserEntity>? seenUsers,
    bool? isNewConversation,
    ParticipantEntity? receiver,
  }) = _MessageEntity;
}
