import 'dart:ui';

import 'package:freezed_annotation/freezed_annotation.dart';

part 'api_state.freezed.dart';

@freezed
class ApiState<T> with _$ApiState<T> {
  const factory ApiState.initial() = _Initial<T>;

  const factory ApiState.loading() = _Loading<T>;

  const factory ApiState.success(T data) = _Success<T>;

  const factory ApiState.failure(String message) = _Failure<T>;
}

// Дополнительные расширения для ApiState
extension ApiStateExtensions<T> on ApiState<T> {
  bool get isLoading => this is _Loading<T>;

  bool get isSuccess => this is _Success<T>;

  bool get isFailure => this is _Failure<T>;

  bool get isInitial => this is _Initial<T>;

  String? get error => maybeWhen(
        failure: (message) => message,
        orElse: () => null,
      );

  void handleApiState({
    required VoidCallback onSuccess,
    void Function(String error)? onError,
  }) {
    if (this.isSuccess) onSuccess();
    if (this.isFailure && onError != null) {
      onError(this.error ?? 'Неизвестная ошибка');
    }
  }
}
