import 'package:dartz/dartz.dart';
import 'package:neighbours/core/error/failures.dart';
import 'package:neighbours/features/chat/domain/entities/message/message_entity.dart';
import 'package:neighbours/features/chat/domain/entities/private_chat_list/private_chat_list_entity.dart';

abstract class PrivateChatRepository {
  Future<Either<Failure, List<MessageEntity>>> fetchPrivateMessages({
    required int receiverId,
    required int page,
    required int limit,
  });

  Future<Either<Failure, List<PrivateChatListEntity>>> fetchPrivateConversations();

  Future<Either<Failure, void>> markPrivateMessagesAsRead(int receiverId);
}
