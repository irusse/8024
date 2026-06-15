import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import 'package:neighbours/core/error/failures.dart';
import 'package:neighbours/features/chat/data/datasources/event_chat_datasource.dart';
import 'package:neighbours/features/chat/domain/entities/message/message_entity.dart';
import 'package:neighbours/features/chat/domain/entities/event_unread_summary/event_unread_summary_entity.dart';
import '../../domain/repositories/event_chat_repository.dart';

@Singleton(as: EventChatRepository)
class EventChatRepositoryImpl implements EventChatRepository {
  final EventChatDataSource _remoteDataSource;

  EventChatRepositoryImpl(this._remoteDataSource);

  @override
  Future<Either<Failure, List<MessageEntity>>> fetchEventMessages({
    required int eventId,
    required int page,
    required int limit,
  }) async {
    final result = await _remoteDataSource.fetchEventMessages(
      eventId: eventId,
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
  Future<Either<Failure, MessageEntity>> sendEventMessage({
    required int eventId,
    required String text,
  }) async {
    final result = await _remoteDataSource.sendEventMessage(
      eventId: eventId,
      text: text,
    );

    return result.fold(
      (failure) => Left(failure),
      (messageModel) => Right(messageModel.toEntity()),
    );
  }

  @override
  Future<Either<Failure, EventUnreadSummaryEntity>> fetchUnreadMessages(
      int userId) async {
    final result = await _remoteDataSource.fetchUnreadMessages(userId);

    return result.fold(
      (failure) => Left(failure),
      (model) => Right(model.toEntity()),
    );
  }

  @override
  Future<Either<Failure, void>> markEventMessagesAsRead(int eventId) async {
    final result = await _remoteDataSource.markEventMessagesAsRead(eventId);

    return result.fold(
      (failure) => Left(failure),
      (_) => const Right(null),
    );
  }
}
