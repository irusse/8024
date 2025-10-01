import 'package:dartz/dartz.dart';
import 'package:neighbours/features/chat/domain/entities/event_unread_summary/event_unread_summary_entity.dart';
import 'package:neighbours/core/error/failures.dart';
import 'package:neighbours/features/chat/domain/entities/message/message_entity.dart';

abstract class EventChatRepository {
  Future<Either<Failure, List<MessageEntity>>> fetchEventMessages({
    required int eventId,
    required int page,
    required int limit,
  });

  Future<Either<Failure, MessageEntity>> sendEventMessage({
    required int eventId,
    required String text,
  });

  Future<Either<Failure, EventUnreadSummaryEntity>> fetchUnreadMessages(
      int userId);

  Future<Either<Failure, void>> markEventMessagesAsRead(int eventId);
}
