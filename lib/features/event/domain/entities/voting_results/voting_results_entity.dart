import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:neighbours/features/event/domain/entities/vote_option/vote_option_entity.dart';

part 'voting_results_entity.freezed.dart';

@freezed
class VotingResultsEntity with _$VotingResultsEntity {
  const factory VotingResultsEntity({
    required int eventId,
    required String votingQuestion,
    required int totalVotes,
    required List<VoteOptionEntity> options,
    required bool hasVoted,
  }) = _VotingResultsEntity;
}
