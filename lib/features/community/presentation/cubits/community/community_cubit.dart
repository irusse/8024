import 'package:bloc/bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:injectable/injectable.dart';
import 'package:neighbours/core/domain/entities/event/participant_entity.dart';
import 'package:neighbours/core/domain/repositories/community_repository.dart';

part 'community_cubit.freezed.dart';

part 'community_state.dart';

@injectable
class CommunityCubit extends Cubit<CommunityState> {
  final CommunityRepository _repository;

  CommunityCubit(this._repository) : super(const CommunityState());

  Future<void> fetchCommunityParticipants(int communityId) async {
    emit(state.copyWith(isParticipantsLoading: true));
    final result = await _repository.getCommunityParticipants(communityId);
    result.fold(
        (failure) => emit(state.copyWith(
            participantsError: failure.message, isParticipantsLoading: false)),
        (participants) => emit(state.copyWith(
            participants: participants, isParticipantsLoading: false)));
  }
}
