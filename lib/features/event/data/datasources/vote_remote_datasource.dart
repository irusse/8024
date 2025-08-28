import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import 'package:neighbours/core/error/failures.dart';
import 'package:neighbours/core/network/network_handler.dart';
import 'package:neighbours/features/event/data/models/voting_results/voting_results_model.dart';

import '../../domain/entities/voting_results/voting_results_entity.dart';

abstract class VoteRemoteDatasource {
  /// Проголосовать в мероприятии
  Future<Either<Failure, void>> vote({
    required int eventId,
    required int optionId,
  });

  /// Отменить голос
  Future<Either<Failure, void>> cancelVote({
    required int eventId,
  });

  /// Получить результаты голосования
  Future<Either<Failure, VotingResultsEntity>> getVotingResults({
    required int eventId,
  });
}

@Singleton(as: VoteRemoteDatasource)
class VoteRemoteDatasourceImpl implements VoteRemoteDatasource {
  final Dio _dio;

  VoteRemoteDatasourceImpl(this._dio);

  @override
  Future<Either<Failure, void>> vote({
    required int eventId,
    required int optionId,
  }) async {
    return NetworkHandler.handleRequest(() async {
      final data = {
        'votingOptionId': optionId,
      };
      await _dio.post('/events/$eventId/vote', data: data);
    });
  }

  @override
  Future<Either<Failure, void>> cancelVote({
    required int eventId,
  }) async {
    return NetworkHandler.handleRequest(() async {
      await _dio.delete('/events/$eventId/vote');
    });
  }

  @override
  Future<Either<Failure, VotingResultsEntity>> getVotingResults({
    required int eventId,
  }) async {
    return NetworkHandler.handleRequest(() async {
      final response = await _dio.get('/events/$eventId/voting-results');
      return VotingResultsModel.fromJson(response.data).toEntity();
    });
  }
}
