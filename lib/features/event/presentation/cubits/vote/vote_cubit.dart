import 'package:bloc/bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:injectable/injectable.dart';
import 'package:neighbours/core/state/api_state.dart';
import 'package:neighbours/features/event/domain/repositories/vote_repository.dart';

import '../../../domain/entities/voting_results/voting_results_entity.dart';

part 'vote_cubit.freezed.dart';

part 'vote_state.dart';

@Injectable()
class VoteCubit extends Cubit<VoteState> {
  final VoteRepository _voteRepository;

  VoteCubit(this._voteRepository) : super(const VoteState());

  Future<void> vote({
    required int eventId,
    required int optionId,
  }) async {
    final previousState = state; // сохраняем для отката

    // Оптимистичное обновление
    final updatedOptions = state.votingResults?.options.map((option) {
      if (option.id == optionId) {
        return option.copyWith(
          votesCount: option.votesCount + 1,
          isVotedByCurrentUser: true,
        );
      } else if (option.isVotedByCurrentUser) {
        // Если раньше голос был за другой вариант, снимаем его
        return option.copyWith(
          votesCount: option.votesCount - 1,
          isVotedByCurrentUser: false,
        );
      }
      return option;
    }).toList();

    emit(state.copyWith(
      votingResults: state.votingResults?.copyWith(
        options: updatedOptions ?? [],
        hasVoted: true,
        totalVotes: (state.votingResults?.totalVotes ?? 0) + 1,
      ),
      voteState: const ApiState.loading(),
    ));

    // Отправляем запрос
    final result = await _voteRepository.vote(
      eventId: eventId,
      optionId: optionId,
    );

    result.fold(
      (failure) {
        // Откат в случае ошибки
        emit(previousState.copyWith(
          voteState: ApiState.failure(failure.message),
        ));
      },
      (_) => emit(state.copyWith(
        voteState: const ApiState.success(null),
      )),
    );
  }

  Future<void> cancelVote({
    required int eventId,
  }) async {
    final previousState = state;

    // Оптимистичное обновление
    final updatedOptions = state.votingResults?.options.map((option) {
      if (option.isVotedByCurrentUser) {
        return option.copyWith(
          votesCount: option.votesCount - 1,
          isVotedByCurrentUser: false,
        );
      }
      return option;
    }).toList();
    final newTotal = (state.votingResults?.totalVotes ?? 0) - 1;
    emit(state.copyWith(
      votingResults: state.votingResults?.copyWith(
        options: updatedOptions ?? [],
        hasVoted: false,
        totalVotes: newTotal < 0 ? 0 : newTotal,
      ),
      cancelVoteState: const ApiState.loading(),
    ));

    // Отправляем запрос
    final result = await _voteRepository.cancelVote(
      eventId: eventId,
    );

    result.fold(
      (failure) {
        emit(previousState.copyWith(
          cancelVoteState: ApiState.failure(failure.message),
        ));
      },
      (_) => emit(state.copyWith(
        cancelVoteState: const ApiState.success(null),
      )),
    );
  }

  Future<void> getVotingResults({
    required int eventId,
  }) async {
    _resetStates();
    emit(state.copyWith(votingResultsState: const ApiState.loading()));

    final result = await _voteRepository.getVotingResults(
      eventId: eventId,
    );

    result.fold(
      (failure) => emit(state.copyWith(
        votingResultsState: ApiState.failure(failure.message),
      )),
      (votingResults) {
        emit(state.copyWith(
          votingResults: votingResults,
          votingResultsState: ApiState.success(votingResults),
        ));
      },
    );
  }

  void _resetStates() {
    emit(state.copyWith(
      voteState: const ApiState.initial(),
      cancelVoteState: const ApiState.initial(),
      votingResultsState: const ApiState.initial(),
    ));
  }

  void clearStates() {
    emit(const VoteState());
  }
}
