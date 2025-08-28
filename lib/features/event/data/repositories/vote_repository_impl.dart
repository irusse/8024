import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import 'package:neighbours/core/error/failures.dart';
import 'package:neighbours/features/event/data/datasources/vote_remote_datasource.dart';
import 'package:neighbours/features/event/domain/repositories/vote_repository.dart';

import '../../domain/entities/voting_results/voting_results_entity.dart';

@Singleton(as: VoteRepository)
class VoteRepositoryImpl implements VoteRepository {
  final VoteRemoteDatasource _remoteDatasource;

  VoteRepositoryImpl(this._remoteDatasource);

  @override
  Future<Either<Failure, void>> vote({
    required int eventId,
    required int optionId,
  }) async {
    return await _remoteDatasource.vote(
      eventId: eventId,
      optionId: optionId,
    );
  }

  @override
  Future<Either<Failure, void>> cancelVote({
    required int eventId,
  }) async {
    return await _remoteDatasource.cancelVote(
      eventId: eventId,
    );
  }

  @override
  Future<Either<Failure, VotingResultsEntity>> getVotingResults({
    required int eventId,
  }) async {
    return await _remoteDatasource.getVotingResults(
      eventId: eventId,
    );
  }
}
