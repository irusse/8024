import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import 'package:neighbours/core/error/failures.dart';
import 'package:neighbours/core/network/network_handler.dart';
import 'package:neighbours/features/chat/data/models/message/message_model.dart';

abstract class CommunityChatDataSource {
  Future<Either<Failure, List<MessageModel>>> fetchCommunityMessages({
    required int communityId,
    required int page,
    required int limit,
  });
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
}
