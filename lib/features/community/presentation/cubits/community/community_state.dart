part of 'community_cubit.dart';

@freezed
abstract class CommunityState with _$CommunityState {
  const factory CommunityState({
    required CommunityEntity community,
    @Default([]) List<ParticipantEntity> participants,
    @Default(ApiState<List<ParticipantEntity>>.initial())
    ApiState<List<ParticipantEntity>> participantsState,
    @Default(ApiState<CommunityEntity>.initial())
    ApiState<CommunityEntity> fetchCommunityState,
  }) = _CommunityState;

  factory CommunityState.initial() => CommunityState(
        community: CommunityEntity(
          id: 0,
          name: '',
          status: '',
          joinCode: '',
          createdBy: '',
          createdAt: DateTime.now(),
        ),
      );
}
