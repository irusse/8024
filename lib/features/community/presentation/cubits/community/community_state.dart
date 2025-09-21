part of 'community_cubit.dart';

@freezed
abstract class CommunityState with _$CommunityState {
  const factory CommunityState({
    required CommunityEntity selectedCommunity,
    @Default([]) List<CommunityEntity> communities,
    @Default([]) List<ParticipantEntity> participants,
    @Default(ApiState<List<ParticipantEntity>>.initial())
    ApiState<List<ParticipantEntity>> participantsState,
    @Default(ApiState<CommunityEntity>.initial())
    ApiState<CommunityEntity> fetchCommunityState,
    @Default(ApiState<UserEntity>.initial())
    ApiState<UserEntity> joinCommunityState,
    @Default(ApiState<UserEntity>.initial())
    ApiState<UserEntity> createCommunityState,
  }) = _CommunityState;

  factory CommunityState.initial() => CommunityState(
        selectedCommunity: CommunityEntity(
          id: 0,
          name: '',
          status: '',
          joinCode: '',
          createdBy: '',
          createdAt: DateTime.now(),
        ),
      );
}
