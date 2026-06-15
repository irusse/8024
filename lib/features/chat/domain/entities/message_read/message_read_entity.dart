import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:neighbours/core/domain/entities/participant/participant_entity.dart';
import 'package:neighbours/features/chat/domain/entities/message/message_entity.dart';

part 'message_read_entity.freezed.dart';

@freezed
abstract class MessageReadEntity with _$MessageReadEntity {
  const factory MessageReadEntity({
    required DateTime seenAt,
    required ParticipantEntity user,
    required MessageEntity message,
  }) = _MessageReadEntity;
}
