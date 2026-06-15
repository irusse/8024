part of 'auth_cubit.dart';

@freezed
abstract class AuthState with _$AuthState {
  const factory AuthState({
    @Default(ApiState<void>.initial()) ApiState<void> loginState,
    @Default(ApiState<void>.initial()) ApiState<void> resendState,
    @Default(ApiState<void>.initial()) ApiState<void> verifyState,
    @Default('') String digits,
    @Default(false) bool isValid,
    required CountryPhoneSpec country,
    String? smsMessage,
    String? smsCode,
  }) = _AuthState;
}
