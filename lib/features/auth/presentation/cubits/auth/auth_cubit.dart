import 'package:bloc/bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:injectable/injectable.dart';
import '../../../domain/repositories/auth_repository.dart';

part 'auth_cubit.freezed.dart';

part 'auth_state.dart';

@injectable
class AuthCubit extends Cubit<AuthState> {
  final AuthRepository _authRepository;

  AuthCubit(this._authRepository) : super(const AuthState.initial());

  Future<void> phoneLogin(String phone) async {
    emit(const AuthState.loading());

    final result = await _authRepository.phoneLogin(phone);

    result.fold(
      (failure) {
        emit(AuthState.error(failure.message));
      },
      (response) {
        if (response.code != null) {
          emit(AuthState.smsSentWithCode(response.message, response.code!));
        } else {
          emit(AuthState.smsSent(response.message));
        }
      },
    );
  }

  Future<void> verifySmsCode(String phone, String code) async {
    emit(const AuthState.loading());

    final result = await _authRepository.verifySmsCode(phone, code);

    result.fold(
      (failure) {
        emit(AuthState.error(failure.message));
      },
      (_) {
        emit(const AuthState.authenticated());
      },
    );
  }
}
