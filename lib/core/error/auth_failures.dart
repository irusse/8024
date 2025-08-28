import 'package:freezed_annotation/freezed_annotation.dart';

part 'auth_failures.freezed.dart';

@freezed
class AuthFailure with _$AuthFailure {
  const factory AuthFailure.tokenExpired() = _TokenExpired;
  const factory AuthFailure.invalidToken() = _InvalidToken;
  const factory AuthFailure.refreshFailed() = _RefreshFailed;
  const factory AuthFailure.maxRefreshAttemptsExceeded() = _MaxRefreshAttemptsExceeded;
  const factory AuthFailure.networkError() = _NetworkError;
  const factory AuthFailure.serverError() = _ServerError;
  const factory AuthFailure.unknown(String message) = _Unknown;

  const AuthFailure._();

  String get message => when(
    tokenExpired: () => 'Токен истек',
    invalidToken: () => 'Недействительный токен',
    refreshFailed: () => 'Не удалось обновить токен',
    maxRefreshAttemptsExceeded: () => 'Превышено максимальное количество попыток обновления',
    networkError: () => 'Ошибка сети',
    serverError: () => 'Ошибка сервера',
    unknown: (message) => message,
  );

  bool get isRecoverable => when(
    tokenExpired: () => true,
    invalidToken: () => false,
    refreshFailed: () => true,
    maxRefreshAttemptsExceeded: () => false,
    networkError: () => true,
    serverError: () => true,
    unknown: (_) => false,
  );
}
