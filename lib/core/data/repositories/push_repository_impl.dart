import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import 'package:neighbours/core/data/datasources/push_remote_datasource.dart';
import 'package:neighbours/core/domain/repositories/push_repository.dart';
import 'package:neighbours/core/error/failures.dart';

@Singleton(as: PushRepository)
class PushRepositoryImpl implements PushRepository {
  final PushRemoteDataSource _remoteDataSource;

  PushRepositoryImpl(this._remoteDataSource);

  @override
  Future<Either<Failure, void>> saveFcmToken(String fcmToken) async {
    return await _remoteDataSource.saveFcmToken(fcmToken);
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
