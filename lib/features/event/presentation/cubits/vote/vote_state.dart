part of 'vote_cubit.dart';

@freezed
abstract class VoteState with _$VoteState {
  const factory VoteState({
     VotingResultsEntity? votingResults,
    @Default(ApiState.initial()) ApiState<void> voteState,
    @Default(ApiState.initial()) ApiState<void> cancelVoteState,
    @Default(ApiState.loading()) ApiState<VotingResultsEntity> votingResultsState,
  }) = _VoteState;
}
