import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:neighbours/core/domain/entities/participant/participant_entity.dart';

part 'message_entity.freezed.dart';

@freezed
abstract class MessageEntity with _$MessageEntity {
  const factory MessageEntity({
    required int id,
    required String text,
    required DateTime createdAt,
    required DateTime updatedAt,
    required int eventId,
    required int userId,
    required ParticipantEntity user,
  }) = _MessageEntity;
}
