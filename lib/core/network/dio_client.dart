import 'package:chucker_flutter/chucker_flutter.dart';
import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:injectable/injectable.dart';
import 'package:neighbours/core/network/jwt_interceptor.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';
import '../config/app_config.dart';

@module
abstract class NetworkModule {
  @singleton
  Dio get dio {
    final dio = Dio(
      BaseOptions(
        baseUrl: AppConfig.baseUrl,
        connectTimeout: const Duration(seconds: 30),
        receiveTimeout: const Duration(seconds: 30),
        sendTimeout: const Duration(seconds: 30),
      ),
    );

    return dio;
  }
}

@singleton
class DioClient {
  final Dio _dio;
  final JWTInterceptor _jwtInterceptor;

  DioClient(this._dio, this._jwtInterceptor) {
    _dio.interceptors.addAll([
      PrettyDioLogger(
        requestHeader: true,
        requestBody: true,
        responseBody: true,
        responseHeader: true,
        error: true,
        compact: true,
        maxWidth: 80,
        logPrint: (obj) => debugPrint(obj.toString()),
      ),
      ChuckerDioInterceptor(),
      _jwtInterceptor,
    ]);
  }

  Dio get dio => _dio;
}
