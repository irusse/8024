part of 'fcm_cubit.dart';

@freezed
abstract class FcmState with _$FcmState {
  const factory FcmState({
    @Default(ApiState<void>.initial()) ApiState<void> updateTokenState,
    @Default(ApiState<void>.initial()) ApiState<void> updateSettingsState,
    @Default(ApiState<void>.initial()) ApiState<void> removeTokenState,
  }) = _FcmState;
}
