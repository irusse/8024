import 'package:bloc/bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:injectable/injectable.dart';
import 'package:neighbours/features/auth/presentation/resources/country_specs.dart';

import '../../../domain/repositories/auth_repository.dart';
import '../../../../../core/state/api_state.dart';
import '../../ui-models/country_phone_spec.dart';

part 'auth_cubit.freezed.dart';

part 'auth_state.dart';

@singleton
class AuthCubit extends Cubit<AuthState> {
  final AuthRepository _authRepository;

  AuthCubit(this._authRepository)
      : super(AuthState(country: CountrySpecs.all[0]));

  Future<void> phoneLogin() async {
    _resetStates();
    emit(state.copyWith(loginState: const ApiState.loading()));

    final phone = "${state.country.dialCode}${state.digits}";
    final result = await _authRepository.phoneLogin(phone);
    result.fold(
      (failure) => emit(state.copyWith(
        loginState: ApiState.failure(failure.message),
      )),
      (response) {
        emit(state.copyWith(
          loginState: const ApiState.success(null),
          smsMessage: response.message,
          smsCode: response.code,
        ));
      },
    );
  }

  Future<void> resendOtp() async {
    _resetStates();
    emit(state.copyWith(resendState: const ApiState.loading(), smsCode: null));

    final phone = "${state.country.dialCode}${state.digits}";
    final result = await _authRepository.phoneLogin(phone);
    result.fold(
      (failure) => emit(state.copyWith(
        resendState: ApiState.failure(failure.message),
      )),
      (response) {
        emit(state.copyWith(
          resendState: const ApiState.success(null),
          smsMessage: response.message,
          smsCode: response.code,
        ));
      },
    );
  }

  Future<void> verifySmsCode(String phone, String code) async {
    _resetStates();
    emit(state.copyWith(verifyState: const ApiState.loading()));

    final result = await _authRepository.verifySmsCode(phone, code);

    result.fold(
      (failure) => emit(state.copyWith(
        verifyState: ApiState.failure(failure.message),
      )),
      (_) => emit(state.copyWith(
        verifyState: const ApiState.success(null),
        isAuthenticated: true,
      )),
    );
  }

  void onPhoneInputChanged({required String digits, required bool isFilled}) {
    emit(state.copyWith(digits: digits, isValid: isFilled));
  }

  void onCountryChanged(CountryPhoneSpec country) {
    emit(state.copyWith(country: country));
  }

  void _resetStates() {
    emit(state.copyWith(
        loginState: const ApiState.initial(),
        verifyState: const ApiState.initial(),
        resendState: const ApiState.initial()));
  }
}
