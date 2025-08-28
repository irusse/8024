import 'package:dartz/dartz.dart';
import 'package:neighbours/core/error/failures.dart';

import '../entities/voting_results/voting_results_entity.dart';


abstract class VoteRepository {
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