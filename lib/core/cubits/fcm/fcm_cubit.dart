import 'package:bloc/bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:injectable/injectable.dart';
import 'package:neighbours/core/domain/repositories/push_repository.dart';
import 'package:neighbours/core/services/fcm_service.dart';

import '../../state/api_state.dart';

part 'fcm_cubit.freezed.dart';

part 'fcm_state.dart';

@singleton
class FcmCubit extends Cubit<FcmState> {
  final FCMService _fcmService;
  final PushRepository _pushRepository;

  FcmCubit(this._pushRepository, this._fcmService) : super(const FcmState());

  Future<void> initFCM() async {
    await _fcmService.init();
  }

  Future<void> saveFcmToken() async {
    _reset();
    final token = await _fcmService.getToken();
    if (token == null) return;
    final result = await _pushRepository.saveFcmToken(token);
    result.fold(
        (failure) => emit(state.copyWith(
              updateTokenState: ApiState.failure(failure.message),
            )),
        (_) => emit(state.copyWith(
              updateTokenState: const ApiState.success(null),
            )));
  }

  /// Обновить настройки push-уведомлений
  Future<void> updatePushNotificationsSettings(bool enabled) async {
    _reset();
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
    _reset();
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

  void onLogout() {
    _fcmService.reset();
  }

  /// Сброс состояний
  void _reset() {
    emit(state.copyWith(
      updateTokenState: const ApiState.initial(),
      updateSettingsState: const ApiState.initial(),
      removeTokenState: const ApiState.initial(),
    ));
  }
}
