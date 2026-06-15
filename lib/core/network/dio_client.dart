import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import 'package:neighbours/core/network/jwt_interceptor.dart';
import 'package:talker_dio_logger/talker_dio_logger_interceptor.dart';
import 'package:talker_dio_logger/talker_dio_logger_settings.dart';
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
      TalkerDioLogger(
        settings: const TalkerDioLoggerSettings(
          printRequestHeaders: true,
          printResponseHeaders: true,
          enabled: true,
          printResponseMessage: true,
          printResponseTime: true,
        ),
      ),
      _jwtInterceptor,
    ]);
  }

  Dio get dio => _dio;
}
