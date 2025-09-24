import 'package:bloc/bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:injectable/injectable.dart';
import 'package:neighbours/core/domain/entities/participant/participant_entity.dart';
import 'package:neighbours/core/domain/entities/user/user_entity.dart';
import 'package:neighbours/core/state/api_state.dart';
import 'package:neighbours/features/community/domain/entities/community/community_entity.dart';
import 'package:neighbours/features/community/domain/repositories/community_repository.dart';

part 'community_cubit.freezed.dart';

part 'community_state.dart';

@singleton
class CommunityCubit extends Cubit<CommunityState> {
  final CommunityRepository _repository;

  CommunityCubit(this._repository) : super(CommunityState());

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
    _reset();
    emit(state.copyWith(
      fetchCommunityState: const ApiState.loading(),
    ));

    final result = await _repository.getCommunityById(id);
    result.fold(
        (failure) => emit(state.copyWith(
              fetchCommunityState: ApiState.failure(failure.message),
            )), (community) {
      final updatedCommunities = state.communities.map((c) {
        return c.id == community.id ? community : c;
      }).toList();
      emit(state.copyWith(
        selectedCommunity: community,
        communities: updatedCommunities,
        fetchCommunityState: ApiState.success(community),
      ));
    });
  }

  void updateCommunity(CommunityEntity community) {
    emit(state.copyWith(selectedCommunity: community));
  }

  void _reset() {
    emit(state.copyWith(
        fetchCommunityState: ApiState.initial(),
        createCommunityState: ApiState.initial(),
        joinCommunityState: ApiState.initial(),
        participantsState: ApiState.initial()));
  }

  Future<UserEntity?> join({
    required String code,
    required double userLatitude,
    required double userLongitude,
  }) async {
    _reset();
    emit(state.copyWith(joinCommunityState: ApiState.loading()));
    final result = await _repository.joinCommunity(
      communityCode: code,
      userLatitude: userLatitude,
      userLongitude: userLongitude,
    );
    return result.fold((failure) {
      emit(state.copyWith(
          joinCommunityState: ApiState.failure(failure.message)));
      return null;
    }, (user) {
      emit(state.copyWith(
          joinCommunityState: ApiState.success(user),
          communities: user.communities));
      return user;
    });
  }

  Future<UserEntity?> create({
    required String name,
    required double userLatitude,
    required double userLongitude,
  }) async {
    _reset();
    emit(state.copyWith(createCommunityState: ApiState.loading()));

    final result = await _repository.createCommunity(
      communityName: name,
      userLatitude: userLatitude,
      userLongitude: userLongitude,
    );

    return result.fold((failure) {
      emit(state.copyWith(
          createCommunityState: ApiState.failure(failure.message)));
      return null;
    }, (user) {
      emit(state.copyWith(
          createCommunityState: ApiState.success(user),
          communities: user.communities));
      return user;
    });
  }
}
