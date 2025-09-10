import 'package:bloc/bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:injectable/injectable.dart';
import 'package:neighbours/core/domain/repositories/push_repository.dart';

import '../../state/api_state.dart';

part 'fcm_cubit.freezed.dart';

part 'fcm_state.dart';

@singleton
class FcmCubit extends Cubit<FcmState> {
  final PushRepository _pushRepository;

  FcmCubit(this._pushRepository) : super(const FcmState());

  Future<void> saveFcmToken(String fcmToken) async {
    await _pushRepository.saveFcmToken(fcmToken);
  }

  /// Обновить настройки push-уведомлений
  Future<void> updatePushNotificationsSettings(bool enabled) async {
    emit(state.copyWith(updateSettingsState: const ApiState.loading()));
    final result =
        await _pushRepository.updatePushNotificationsSettings(enabled);
    result.fold(
      (failure) => emit(state.copyWith(
        updateSettingsState: ApiState.failure(failure.message),
      )),
      (_) => emit(state.copyWith(
        updateSettingsState: const ApiState.success(null),
      )),
    );
  }

  /// Удалить FCM токен
  Future<void> removeFcmToken() async {
    emit(state.copyWith(removeTokenState: const ApiState.loading()));
    final result = await _pushRepository.removeFcmToken();
    result.fold(
      (failure) => emit(state.copyWith(
        removeTokenState: ApiState.failure(failure.message),
      )),
      (_) => emit(state.copyWith(
        removeTokenState: const ApiState.success(null),
      )),
    );
  }

  /// Сброс состояний
  void reset() {
    emit(state.copyWith(
      updateTokenState: const ApiState.initial(),
      updateSettingsState: const ApiState.initial(),
      removeTokenState: const ApiState.initial(),
    ));
  }
}
