import 'package:dartz/dartz.dart';
import '../../error/failures.dart';

abstract class PushRepository {
  Future<Either<Failure, void>> saveFcmToken(String fcmToken);

  /// Настройки push-уведомлений
  Future<Either<Failure, void>> updatePushNotificationsSettings(
      bool pushNotificationsEnabled);

  /// Удалить FCM токен
  Future<Either<Failure, void>> removeFcmToken();
}
