import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import 'package:neighbours/core/error/failures.dart';
import 'package:neighbours/core/network/network_handler.dart';

import '../../../../core/data/models/sms_response/sms_response_model.dart';
import '../models/verify_sms_response_model.dart';

abstract class AuthRemoteDataSource {
  Future<Either<Failure, SmsResponseModel>> phoneLogin(String phone);

  Future<Either<Failure, VerifySmsResponseModel>> verifySmsCode(
      String phone, String code);
}

@Singleton(as: AuthRemoteDataSource)
class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final Dio _dio;

  AuthRemoteDataSourceImpl(this._dio);

  @override
  Future<Either<Failure, SmsResponseModel>> phoneLogin(String phone) async {
    return NetworkHandler.handleRequest(() async {
      final response = await _dio.post('/auth/send-sms', data: {
        'phone': phone,
      });
      return SmsResponseModel.fromJson(response.data);
    });
  }

  @override
  Future<Either<Failure, VerifySmsResponseModel>> verifySmsCode(
      String phone, String code) async {
    return NetworkHandler.handleRequest(() async {
      final response = await _dio.post('/auth/verify-sms', data: {
        'phone': phone,
        'code': code,
      });
      return VerifySmsResponseModel.fromJson(response.data);
    });
  }
}
