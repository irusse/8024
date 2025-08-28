import 'package:bloc/bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

import '../../../../auth/domain/repositories/auth_repository.dart';

part 'profile_cubit.freezed.dart';

part 'profile_state.dart';

@injectable
class ProfileCubit extends Cubit<ProfileState> {
  final AuthRepository _authRepository;

  ProfileCubit(this._authRepository) : super(const ProfileState.initial());

  Future<void> logout() async {
    emit(const ProfileState.logoutLoading());
    try {
      await _authRepository.logout();
      emit(const ProfileState.logoutSuccess());
    } catch (e) {
      emit(ProfileState.error(e.toString()));
    }
  }
}
