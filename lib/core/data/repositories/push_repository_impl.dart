import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import 'package:neighbours/core/data/datasources/push_remote_datasource.dart';
import 'package:neighbours/core/data/datasources/push_local_datasource.dart';
import 'package:neighbours/core/domain/repositories/push_repository.dart';
import 'package:neighbours/core/error/failures.dart';

@Singleton(as: PushRepository)
class PushRepositoryImpl implements PushRepository {
  final PushRemoteDataSource _remoteDataSource;
  final PushLocalDataSource _localDataSource;

  PushRepositoryImpl(this._remoteDataSource, this._localDataSource);

  @override
  Future<Either<Failure, void>> updateFcmToken() async {
    return await _remoteDataSource.updateFcmToken();
  }

  @override
  Future<Either<Failure, void>> updateCachedFcmToken() async {
    return await _remoteDataSource.updateCachedFcmToken();
  }

  @override
  Future<void> saveFcmToken(String fcmToken) async {
    await _localDataSource.saveFcmToken(fcmToken);
  }

  @override
  Future<String?> getCachedFcmToken() async {
    return await _localDataSource.getFcmToken();
  }

  @override
  Future<Either<Failure, void>> updatePushNotificationsSettings(
      bool pushNotificationsEnabled) async {
    return await _remoteDataSource
        .updatePushNotificationsSettings(pushNotificationsEnabled);
  }

  @override
  Future<Either<Failure, void>> removeFcmToken() async {
    return await _remoteDataSource.removeFcmToken();
  }
}
