import 'package:dartz/dartz.dart';
import 'package:neighbours/core/error/failures.dart';
import 'package:neighbours/features/chat/domain/entities/community_unread_summary/community_unread_summary_entity.dart';
import 'package:neighbours/features/chat/domain/entities/message/message_entity.dart';

abstract class CommunityChatRepository {
  Future<Either<Failure, List<MessageEntity>>> fetchCommunityMessages({
    required int communityId,
    required int page,
    required int limit,
  });

  Future<Either<Failure, CommunityUnreadSummaryEntity>> fetchUnreadMessages(
      int userId);

  Future<Either<Failure, void>> markCommunityMessagesAsRead(int communityId);
}
