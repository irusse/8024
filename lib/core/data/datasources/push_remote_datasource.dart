import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import 'package:neighbours/core/network/network_handler.dart';
import 'package:neighbours/core/data/datasources/push_local_datasource.dart';

import '../../error/failures.dart';

abstract class PushRemoteDataSource {
  /// Обновить FCM токен
  Future<Either<Failure, void>> updateFcmToken();

  /// Обновить FCM токен из кэша
  Future<Either<Failure, void>> updateCachedFcmToken();

  /// Настройки push-уведомлений
  Future<Either<Failure, void>> updatePushNotificationsSettings(
      bool pushNotificationsEnabled);

  /// Удалить FCM токен
  Future<Either<Failure, void>> removeFcmToken();
}

@Singleton(as: PushRemoteDataSource)
class PushRemoteDataSourceImpl implements PushRemoteDataSource {
  final Dio _dio;
  final PushLocalDataSource _localDataSource;

  PushRemoteDataSourceImpl(this._dio, this._localDataSource);

  @override
  Future<Either<Failure, void>> updateFcmToken() async {
    final fcmToken = await _localDataSource.getFcmToken();
    if (fcmToken == null) return const Right(null);
    return NetworkHandler.handleRequest(() async {
      await _dio.patch(
        '/users/fcm-token',
        data: {'fcmToken': fcmToken},
      );
      // Сохраняем токен в локальное хранилище после успешной отправки
      await _localDataSource.saveFcmToken(fcmToken);
    });
  }

  @override
  Future<Either<Failure, void>> updateCachedFcmToken() async {
    return NetworkHandler.handleRequest(() async {
      final cachedToken = await _localDataSource.getFcmToken();
      if (cachedToken == null) {
        throw Exception('FCM токен не найден в кэше');
      }
      await _dio.patch(
        '/users/fcm-token',
        data: {'fcmToken': cachedToken},
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
      // Удаляем токен из локального хранилища после успешного удаления
      await _localDataSource.removeFcmToken();
    });
  }
}
