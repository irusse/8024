import 'package:dartz/dartz.dart';
import 'package:neighbours/core/error/failures.dart';
import 'package:neighbours/features/chat/domain/entities/message/message_entity.dart';

abstract class PrivateChatRepository {
  Future<Either<Failure, List<MessageEntity>>> fetchPrivateMessages({
    required int conversationId,
    required int page,
    required int limit,
  });
}
