import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import 'package:neighbours/core/error/failures.dart';
import 'package:neighbours/core/network/network_handler.dart';
import 'package:neighbours/features/chat/data/models/community_unread_summary/community_unread_summary_model.dart';
import 'package:neighbours/features/chat/data/models/message/message_model.dart';

abstract class CommunityChatDataSource {
  Future<Either<Failure, List<MessageModel>>> fetchCommunityMessages({
    required int communityId,
    required int page,
    required int limit,
  });

  Future<Either<Failure, CommunityUnreadSummaryModel>> fetchUnreadMessages(int userId);

  Future<Either<Failure, void>> markCommunityMessagesAsRead(int communityId);
}

@Singleton(as: CommunityChatDataSource)
class CommunityChatDataSourceImpl implements CommunityChatDataSource {
  final Dio _dio;

  CommunityChatDataSourceImpl(this._dio);

  @override
  Future<Either<Failure, List<MessageModel>>> fetchCommunityMessages({
    required int communityId,
    required int page,
    required int limit,
  }) async {
    return NetworkHandler.handleRequest(() async {
      final response = await _dio.get(
        '/communities/$communityId/messages',
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
  Future<Either<Failure, CommunityUnreadSummaryModel>> fetchUnreadMessages(
      int userId) async {
    return NetworkHandler.handleRequest(() async {
      final response = await _dio.get('/communities/messages/unread',
          queryParameters: {'userId': userId});

      return CommunityUnreadSummaryModel.fromJson(response.data);
    });
  }

  @override
  Future<Either<Failure, void>> markCommunityMessagesAsRead(int communityId) async {
    return NetworkHandler.handleRequest(() async {
      await _dio.post('/communities/$communityId/read');
    });
  }
}
