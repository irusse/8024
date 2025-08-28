import 'package:bloc/bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:image_picker/image_picker.dart';
import 'package:injectable/injectable.dart';
import 'package:neighbours/core/domain/entities/profile_deletion/profile_deletion_entity.dart';
import 'package:neighbours/core/domain/entities/sms_response/sms_response_entity.dart';
import 'package:neighbours/core/domain/entities/user/user_entity.dart';
import 'package:neighbours/core/domain/repositories/user_repository.dart';

import '../../state/api_state.dart';

part 'user_cubit.freezed.dart';

part 'user_state.dart';

@singleton
class UserCubit extends Cubit<UserState> {
  final UserRepository _userRepository;

  UserCubit(this._userRepository) : super(UserState.initial());

  Future<void> fetchUser() async {
    reset();
    emit(state.copyWith(fetchState: const ApiState.loading()));
    final result = await _userRepository.fetchUser();
    result.fold(
        (failure) => emit(state.copyWith(
              fetchState: ApiState.failure(failure.message),
            )),
        (userEntity) => emit(state.copyWith(
            user: userEntity, fetchState: const ApiState.success(null))));
  }

  Future<void> updateUser(UserEntity user, {XFile? avatarFile}) async {
    reset();
    emit(state.copyWith(updateState: const ApiState.loading()));
    final result =
        await _userRepository.updateUser(user, avatarFile: avatarFile);
    result.fold(
        (failure) => emit(
            state.copyWith(updateState: ApiState.failure(failure.message))),
        (userEntity) => emit(state.copyWith(
            user: userEntity, updateState: const ApiState.success(null))));
  }

  void setUser(UserEntity user) {
    emit(state.copyWith(user: user));
  }

  void setInitial() {
    emit(UserState.initial());
  }

  void reset() {
    emit(state.copyWith(
        confirmProfileDeletion: const ApiState.initial(),
        requestProfileDeletion: const ApiState.initial(),
        restoreProfile: const ApiState.initial(),
        updateState: const ApiState.initial(),
        fetchState: const ApiState.initial()));
  }

  Future<void> requestProfileDeletion() async {
    reset();
    emit(state.copyWith(requestProfileDeletion: const ApiState.loading()));
    final result = await _userRepository.requestProfileDeletion();
    result.fold(
      (failure) => emit(state.copyWith(
          requestProfileDeletion: ApiState.failure(failure.message))),
      (smsResponse) => emit(state.copyWith(
        requestProfileDeletion: ApiState.success(smsResponse),
      )),
    );
  }

  Future<void> confirmProfileDeletion(String code) async {
    reset();
    emit(state.copyWith(confirmProfileDeletion: const ApiState.loading()));
    final result = await _userRepository.confirmProfileDeletion(code);
    result.fold(
      (failure) => emit(state.copyWith(
        confirmProfileDeletion: ApiState.failure(failure.message),
      )),
      (profileDeletion) => emit(state.copyWith(
          confirmProfileDeletion: ApiState.success(profileDeletion),
          user: state.user.copyWith(
              deletionScheduledAt: profileDeletion.deletionScheduledAt))),
    );
  }

  Future<void> restoreProfile() async {
    reset();
    emit(state.copyWith(restoreProfile: const ApiState.loading()));
    final result = await _userRepository.restoreProfile();
    result.fold(
      (failure) => emit(state.copyWith(
        restoreProfile: ApiState.failure(failure.message),
      )),
      (message) => emit(state.copyWith(
        user: state.user.copyWith(deletionScheduledAt: null),
        restoreProfile: ApiState.success(message),
      )),
    );
  }
}
