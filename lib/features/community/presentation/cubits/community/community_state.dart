part of 'community_cubit.dart';

@freezed
class CommunityState with _$CommunityState {
  const factory CommunityState({
    @Default(false) bool isParticipantsLoading,
    @Default([]) List<ParticipantEntity> participants,
    String? participantsError,
  }) = _CommunityState;
}
