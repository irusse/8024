import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import 'package:neighbours/core/error/failures.dart';
import 'package:neighbours/core/network/network_handler.dart';
import 'package:neighbours/features/chat/data/models/message/message_model.dart';
import 'package:neighbours/features/chat/data/models/private_chat_list/private_chat_list_model.dart';

abstract class PrivateChatDataSource {
  Future<Either<Failure, List<MessageModel>>> fetchPrivateMessages({
    required int receiverId,
    required int page,
    required int limit,
  });

  Future<Either<Failure, List<PrivateChatListModel>>>
      fetchPrivateConversations();

  Future<Either<Failure, void>> markPrivateMessagesAsRead(int receiverId);
}

@Singleton(as: PrivateChatDataSource)
class PrivateChatDataSourceImpl implements PrivateChatDataSource {
  final Dio _dio;

  PrivateChatDataSourceImpl(this._dio);

  @override
  Future<Either<Failure, List<MessageModel>>> fetchPrivateMessages({
    required int receiverId,
    required int page,
    required int limit,
  }) async {
    return NetworkHandler.handleRequest(() async {
      final response = await _dio.get(
        '/private-chat/conversations/$receiverId/messages',
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
  Future<Either<Failure, List<PrivateChatListModel>>>
      fetchPrivateConversations() async {
    return NetworkHandler.handleRequest(() async {
      final response = await _dio.get('/private-chat/conversations');

      final data = response.data as List;
      return data.map((json) => PrivateChatListModel.fromJson(json)).toList();
    });
  }

  @override
  Future<Either<Failure, void>> markPrivateMessagesAsRead(
      int conversationId) async {
    return NetworkHandler.handleRequest(() async {
      await _dio.post('/private-chat/$conversationId/read');
      return null;
    });
  }
}
