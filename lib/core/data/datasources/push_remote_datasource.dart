import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import 'package:neighbours/core/network/network_handler.dart';

import '../../error/failures.dart';

abstract class PushRemoteDataSource {
  /// Обновить FCM токен
  Future<Either<Failure, void>> saveFcmToken(String token);

  /// Настройки push-уведомлений
  Future<Either<Failure, void>> updatePushNotificationsSettings(
      bool pushNotificationsEnabled);

  /// Удалить FCM токен
  Future<Either<Failure, void>> removeFcmToken();
}

@Singleton(as: PushRemoteDataSource)
class PushRemoteDataSourceImpl implements PushRemoteDataSource {
  final Dio _dio;

  PushRemoteDataSourceImpl(this._dio);

  @override
  Future<Either<Failure, void>> saveFcmToken(String token) async {
    return NetworkHandler.handleRequest(() async {
      await _dio.patch(
        '/users/fcm-token',
        data: {'fcmToken': token},
      );
    });
  }

  @override
  Future<Either<Failure, void>> updatePushNotificationsSettings(
      bool pushNotificationsEnabled) async {
    return NetworkHandler.handleRequest(() async {
      await _dio.patch(
        '/users/push-notifications',
        data: {'pushNotificationsEnabled': pushNotificationsEnabled},
      );
    });
  }

  @override
  Future<Either<Failure, void>> removeFcmToken() async {
    return NetworkHandler.handleRequest(() async {
      await _dio.post('/users/fcm-token/remove');
    });
  }
}
