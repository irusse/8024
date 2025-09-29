import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import 'package:neighbours/core/data/models/unread_summary/unread_summary_model.dart';
import 'package:neighbours/core/error/failures.dart';
import 'package:neighbours/core/network/network_handler.dart';
import 'package:neighbours/features/chat/data/models/message/message_model.dart';

abstract class EventChatDataSource {
  Future<Either<Failure, List<MessageModel>>> fetchEventMessages({
    required int eventId,
    required int page,
    required int limit,
  });

  Future<Either<Failure, MessageModel>> sendEventMessage({
    required int eventId,
    required String text,
  });

  Future<Either<Failure, UnreadSummaryModel>> fetchUnreadMessages(int userId);

  Future<Either<Failure, void>> markEventMessagesAsRead(int eventId);
}

@Singleton(as: EventChatDataSource)
class EventChatDataSourceImpl implements EventChatDataSource {
  final Dio _dio;

  EventChatDataSourceImpl(this._dio);

  @override
  Future<Either<Failure, List<MessageModel>>> fetchEventMessages({
    required int eventId,
    required int page,
    required int limit,
  }) async {
    return NetworkHandler.handleRequest(() async {
      final response = await _dio.get(
        '/events/$eventId/messages',
        queryParameters: {
          'page': page,
          'limit': limit,
        },
      );

      final data = response.data as List;
      return data.map((json) => MessageModel.fromJson(json)).toList();
    });
  }

  @override
  Future<Either<Failure, MessageModel>> sendEventMessage({
    required int eventId,
    required String text,
  }) async {
    return NetworkHandler.handleRequest(() async {
      final data = {
        'text': text.trim(),
      };

      final response = await _dio.post('/events/$eventId/messages', data: data);
      return MessageModel.fromJson(response.data);
    });
  }

  @override
  Future<Either<Failure, UnreadSummaryModel>> fetchUnreadMessages(
      int userId) async {
    return NetworkHandler.handleRequest(() async {
      final response = await _dio
          .get('/events/messages/unread', queryParameters: {'userId': userId});

      return UnreadSummaryModel.fromJson(response.data);
    });
  }

  @override
  Future<Either<Failure, void>> markEventMessagesAsRead(int eventId) async {
    return NetworkHandler.handleRequest(() async {
      await _dio.post('/events/$eventId/read');
    });
  }
}
