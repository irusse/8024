import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import 'package:neighbours/core/error/failures.dart';

import '../../../../core/services/auth_service.dart';
import '../../../../core/domain/entities/sms_response/sms_response_entity.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_remote_data_source.dart';

@Singleton(as: AuthRepository)
class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource _remoteDataSource;
  final AuthService _authService;

  AuthRepositoryImpl(this._remoteDataSource, this._authService);

  @override
  Future<void> logout() async {
     _authService.clearTokens();
  }

  @override
  Future<Either<Failure,SmsResponseEntity>> phoneLogin(String phone) async {
    final result = await _remoteDataSource.phoneLogin(phone);
    return result.fold((failure) => Left(failure), (res)=>Right(res.toEntity()));
  }

  @override
  Future<Either<Failure,void>> verifySmsCode(String phone, String code) async {
    final result = await _remoteDataSource.verifySmsCode(phone, code);

  return result.fold(
    (failure) => Left(failure),
    (res) async {
      await _authService.saveTokens(
        accessToken: res.accessToken,
        refreshToken: res.refreshToken,
      );
      return const Right(null);
    },
  );
   
  }
}
