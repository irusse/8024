import 'package:bloc/bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:injectable/injectable.dart';
import 'package:neighbours/core/domain/entities/participant/participant_entity.dart';
import 'package:neighbours/core/state/api_state.dart';
import 'package:neighbours/features/community/domain/entities/community/community_entity.dart';
import 'package:neighbours/features/community/domain/repositories/community_repository.dart';

part 'community_cubit.freezed.dart';

part 'community_state.dart';

@injectable
class CommunityCubit extends Cubit<CommunityState> {
  final CommunityRepository _repository;

  CommunityCubit(this._repository) : super(CommunityState.initial());

  Future<void> fetchCommunityParticipants(int communityId) async {
    emit(state.copyWith(
      participantsState: const ApiState.loading(),
    ));

    final result = await _repository.getCommunityParticipants(communityId);
    result.fold(
      (failure) => emit(state.copyWith(
        participantsState: ApiState.failure(failure.message),
      )),
      (participants) => emit(state.copyWith(
        participants: participants,
        participantsState: ApiState.success(participants),
      )),
    );
  }

  Future<void> getCommunityById(int id) async {
    emit(state.copyWith(
      fetchCommunityState: const ApiState.loading(),
    ));

    final result = await _repository.getCommunityById(id);
    result.fold(
      (failure) => emit(state.copyWith(
        fetchCommunityState: ApiState.failure(failure.message),
      )),
      (community) => emit(state.copyWith(
        community: community,
        fetchCommunityState: ApiState.success(community),
      )),
    );
  }

  /// Обновляет текущее сообщество в состоянии
  void updateCommunity(CommunityEntity community) {
    emit(state.copyWith(community: community));
  }

  /// Сбрасывает состояние к начальному
  void reset() {
    emit(CommunityState.initial());
  }
}
