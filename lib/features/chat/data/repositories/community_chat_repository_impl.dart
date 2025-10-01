import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import 'package:neighbours/core/error/failures.dart';
import 'package:neighbours/features/chat/data/datasources/community_chat_datasource.dart';
import 'package:neighbours/features/chat/domain/entities/community_unread_summary/community_unread_summary_entity.dart';
import 'package:neighbours/features/chat/domain/entities/message/message_entity.dart';
import '../../domain/repositories/community_chat_repository.dart';

@Singleton(as: CommunityChatRepository)
class CommunityChatRepositoryImpl implements CommunityChatRepository {
  final CommunityChatDataSource _remoteDataSource;

  CommunityChatRepositoryImpl(this._remoteDataSource);

  @override
  Future<Either<Failure, List<MessageEntity>>> fetchCommunityMessages({
    required int communityId,
    required int page,
    required int limit,
  }) async {
    final result = await _remoteDataSource.fetchCommunityMessages(
      communityId: communityId,
      page: page,
      limit: limit,
    );

    return result.fold(
      (failure) => Left(failure),
      (messageModels) =>
          Right(messageModels.map((model) => model.toEntity()).toList()),
    );
  }

  @override
  Future<Either<Failure, CommunityUnreadSummaryEntity>> fetchUnreadMessages(
      int userId) async {
    final result = await _remoteDataSource.fetchUnreadMessages(userId);

    return result.fold(
      (failure) => Left(failure),
      (model) => Right(model.toEntity()),
    );
  }

  @override
  Future<Either<Failure, void>> markCommunityMessagesAsRead(int communityId) async {
    final result = await _remoteDataSource.markCommunityMessagesAsRead(communityId);

    return result.fold(
      (failure) => Left(failure),
      (_) => const Right(null),
    );
  }
}
