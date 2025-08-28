import 'package:dartz/dartz.dart';
import 'package:neighbours/core/domain/entities/message/message_entity.dart';
import 'package:neighbours/core/domain/entities/unread_summary/unread_summary_entity.dart';
import 'package:neighbours/core/error/failures.dart';

abstract class ChatRepository {
  Future<Either<Failure, List<MessageEntity>>> fetchEventMessages({
    required int eventId,
    required int page,
    required int limit,
  });

  Future<Either<Failure, MessageEntity>> sendEventMessage({
    required int eventId,
    required String text,
  });

  Future<Either<Failure, UnreadSummaryEntity>> fetchUnreadMessages(
      int userId);

  Future<Either<Failure, void>> markEventMessagesAsRead(int eventId);
}
