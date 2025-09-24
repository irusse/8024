part of 'other_profile_cubit.dart';

@freezed
abstract class OtherProfileState with _$OtherProfileState {
  const factory OtherProfileState({
    OtherUserEntity? user,
    @Default(ApiState.initial()) ApiState<void> fetchUserState,
  }) = _OtherProfileState;
}
