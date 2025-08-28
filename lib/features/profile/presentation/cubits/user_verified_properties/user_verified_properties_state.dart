part of 'user_verified_properties_cubit.dart';

@freezed
class UserVerifiedPropertiesState with _$UserVerifiedPropertiesState {
  const factory UserVerifiedPropertiesState({
    @Default([]) List<UserVerifiedPropertyEntity> verifications,
    @Default(ApiState<void>.initial()) ApiState<void> fetchState,
  }) = _UserVerifiedPropertiesState;
}
