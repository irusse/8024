import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import 'package:neighbours/core/error/failures.dart';
import 'package:neighbours/features/chat/data/datasources/private_chat_datasource.dart';
import 'package:neighbours/features/chat/domain/entities/message/message_entity.dart';
import '../../domain/repositories/private_chat_repository.dart';

@Singleton(as: PrivateChatRepository)
class PrivateChatRepositoryImpl implements PrivateChatRepository {
  final PrivateChatDataSource _remoteDataSource;

  PrivateChatRepositoryImpl(this._remoteDataSource);

  @override
  Future<Either<Failure, List<MessageEntity>>> fetchPrivateMessages({
    required int conversationId,
    required int page,
    required int limit,
  }) async {
    final result = await _remoteDataSource.fetchPrivateMessages(
      conversationId: conversationId,
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
  Future<Either<Failure, void>> markPrivateMessagesAsRead(int conversationId) async {
    final result = await _remoteDataSource.markPrivateMessagesAsRead(conversationId);
    return result.fold(
      (failure) => Left(failure),
      (_) => const Right(null),
    );
  }
}
