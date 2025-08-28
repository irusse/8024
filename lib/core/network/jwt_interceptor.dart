import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:injectable/injectable.dart';
import 'dart:async';

import '../../features/auth/data/models/verify_sms_response_model.dart';
import '../services/auth_service.dart';
import '../services/navigation_service.dart';

@singleton
class JWTInterceptor extends Interceptor {
  final Dio _dio;
  final AuthService _authService;
  final NavigationService _navigationService;

  // Защита от бесконечных циклов
  static const int _maxRefreshAttempts = 3;
  static const Duration _refreshTimeout = Duration(seconds: 10);

  // Текущий refresh запрос для предотвращения дублирования
  Completer<String?>? _refreshCompleter;
  int _refreshAttempts = 0;
  bool _isRefreshing = false;

  JWTInterceptor(
    this._dio,
    this._authService,
    this._navigationService,
  );

  @override
  void onRequest(
      RequestOptions options, RequestInterceptorHandler handler) async {
    try {
      // Не подставляем токен для refresh запроса
      if (options.extra['refreshCall'] == true) {
        debugPrint('[JWTInterceptor] Skip token for refreshCall');
        handler.next(options);
        return;
      }

      final accessToken = await _authService.getValidAccessToken();
      if (accessToken != null) {
        options.headers['Authorization'] = 'Bearer $accessToken';
        debugPrint(accessToken);
        debugPrint('[JWTInterceptor] Attached access token.');
      } else {
        debugPrint('[JWTInterceptor] No valid access token found.');
      }
      handler.next(options);
    } catch (e) {
      debugPrint('[JWTInterceptor] Error in onRequest: $e');
      handler.next(options);
    }
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    debugPrint('[JWTInterceptor] onError triggered');
    debugPrint('[JWTInterceptor] statusCode: ${err.response?.statusCode}');
    debugPrint('[JWTInterceptor] extra: ${err.requestOptions.extra}');

    final isRefreshCall = err.requestOptions.extra['refreshCall'] == true;

    if (err.response?.statusCode == 401 && !isRefreshCall) {
      debugPrint('[JWTInterceptor] Detected 401. Attempting refresh...');

      try {
        final newToken = await _handleTokenRefresh();
        if (newToken != null) {
          // Повторяем оригинальный запрос с новым токеном
          final retryResponse =
              await _retryRequest(err.requestOptions, newToken);
          return handler.resolve(retryResponse);
        } else {
          // Refresh не удался, выходим из системы
          await _handleLogout();
          return handler.next(err);
        }
      } catch (e) {
        debugPrint('[JWTInterceptor] Error during token refresh: $e');
        await _handleLogout();
        return handler.next(err);
      }
    } else {
      // Не 401 или уже refresh запрос → просто передаем ошибку
      debugPrint('[JWTInterceptor] Passing error downstream.');
      return handler.next(err);
    }
  }

  /// Обрабатывает refresh токена с защитой от дублирования и бесконечных циклов
  Future<String?> _handleTokenRefresh() async {
    // Проверяем лимит попыток
    if (_refreshAttempts >= _maxRefreshAttempts) {
      debugPrint('[JWTInterceptor] Max refresh attempts reached. Logging out.');
      return null;
    }

    // Если уже идет refresh, ждем его завершения
    if (_isRefreshing && _refreshCompleter != null) {
      debugPrint('[JWTInterceptor] Refresh already in progress, waiting...');
      return await _refreshCompleter!.future;
    }

    // Начинаем новый refresh
    _isRefreshing = true;
    _refreshCompleter = Completer<String?>();
    _refreshAttempts++;

    try {
      debugPrint(
          '[JWTInterceptor] Starting token refresh (attempt $_refreshAttempts)');

      final refreshToken = await _authService.getValidRefreshToken();
      if (refreshToken == null) {
        debugPrint('[JWTInterceptor] No valid refresh token found.');
        _refreshCompleter!.complete(null);
        return null;
      }

      // Выполняем refresh с таймаутом
      final refreshResponse = await _dio
          .post(
            '/auth/refresh',
            data: {'refreshToken': refreshToken},
            options: Options(
              extra: {'refreshCall': true},
              sendTimeout: _refreshTimeout,
              receiveTimeout: _refreshTimeout,
            ),
          )
          .timeout(_refreshTimeout);

      debugPrint('[JWTInterceptor] Refresh response received');

      final tokens = VerifySmsResponseModel.fromJson(refreshResponse.data);

      // Сохраняем новые токены
      await _authService.saveTokens(
        accessToken: tokens.accessToken,
        refreshToken: tokens.refreshToken,
      );

      debugPrint('[JWTInterceptor] New tokens saved successfully');

      // Сбрасываем счетчик попыток при успехе
      _refreshAttempts = 0;

      _refreshCompleter!.complete(tokens.accessToken);
      return tokens.accessToken;
    } catch (e) {
      debugPrint('[JWTInterceptor] Refresh failed: $e');

      // Если это последняя попытка, очищаем токены
      if (_refreshAttempts >= _maxRefreshAttempts) {
        await _authService.clearTokens();
      }

      _refreshCompleter!.complete(null);
      return null;
    } finally {
      _isRefreshing = false;
      _refreshCompleter = null;
    }
  }

  /// Повторяет оригинальный запрос с новым токеном
  Future<Response> _retryRequest(
      RequestOptions requestOptions, String newToken) async {
    debugPrint(
        '[JWTInterceptor] Retrying original request: ${requestOptions.path}');

    // Обновляем заголовки с новым токеном
    final newHeaders = Map<String, dynamic>.from(requestOptions.headers);
    newHeaders['Authorization'] = 'Bearer $newToken';

    // Создаем новые опции с флагом refreshCall
    final newOptions = Options(
      method: requestOptions.method,
      headers: newHeaders,
      responseType: requestOptions.responseType,
      contentType: requestOptions.contentType,
      extra: {
        ...requestOptions.extra,
        'refreshCall': true,
      },
      followRedirects: requestOptions.followRedirects,
      validateStatus: requestOptions.validateStatus,
      receiveDataWhenStatusError: requestOptions.receiveDataWhenStatusError,
    );

    // Повторяем запрос
    return await _dio.request(
      requestOptions.path,
      options: newOptions,
      data: requestOptions.data,
      queryParameters: requestOptions.queryParameters,
    );
  }

  /// Сбрасывает состояние interceptor'а
  void reset() {
    _refreshAttempts = 0;
    _isRefreshing = false;
    _refreshCompleter?.complete(null);
    _refreshCompleter = null;
  }

  Future<void> _handleLogout() async {
    debugPrint('[JWTInterceptor] Handling logout');
    reset();
    await _authService.clearTokens();
    _navigationService.goToLogin();
  }
}
