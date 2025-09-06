import 'package:dartz/dartz.dart';
import '../../error/failures.dart';

abstract class PushRepository {
  /// Обновить FCM токен
  Future<Either<Failure, void>> updateFcmToken();

  /// Обновить FCM токен из кэша
  Future<Either<Failure, void>> updateCachedFcmToken();

  /// Сохранить FCM токен в локальное хранилище
  Future<void> saveFcmToken(String fcmToken);

  /// Получить FCM токен из локального хранилища
  Future<String?> getCachedFcmToken();

  /// Настройки push-уведомлений
  Future<Either<Failure, void>> updatePushNotificationsSettings(
      bool pushNotificationsEnabled);

  /// Удалить FCM токен
  Future<Either<Failure, void>> removeFcmToken();
}
