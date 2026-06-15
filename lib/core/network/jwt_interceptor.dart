import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import 'package:neighbours/core/logging/logger.dart';
import 'dart:async';

import '../../features/auth/data/models/verify_sms_response_model.dart';
import '../services/auth_service.dart';

@singleton
class JWTInterceptor extends Interceptor {
  final Dio _dio;
  final AuthService _authService;

  static const int _maxRefreshAttempts = 3;
  static const Duration _refreshTimeout = Duration(seconds: 10);
  static const _tag = "JWTInterceptor";

  Completer<String?>? _refreshCompleter;
  int _refreshAttempts = 0;
  bool _isRefreshing = false;

  JWTInterceptor(
    this._dio,
    this._authService,
  );

  @override
  void onRequest(
      RequestOptions options, RequestInterceptorHandler handler) async {
    try {
      if (options.extra['refreshCall'] == true) {
        AppLogger.info("Skip token for refreshCall", tag: _tag);
        handler.next(options);
        return;
      }

      final accessToken = await _authService.getValidAccessToken();
      if (accessToken != null) {
        options.headers['Authorization'] = 'Bearer $accessToken';
      } else {
        AppLogger.info("No valid access token found.", tag: _tag);
      }
      handler.next(options);
    } catch (e) {
      AppLogger.error("Error in onRequest", tag: _tag, error: e);
      handler.next(options);
    }
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    AppLogger.error("onError triggered", tag: _tag, error: err);
    AppLogger.info("statusCode: ${err.response?.statusCode}", tag: _tag);
    AppLogger.info("extra: ${err.requestOptions.extra}", tag: _tag);

    final isRefreshCall = err.requestOptions.extra['refreshCall'] == true;

    if (err.response?.statusCode == 401 && !isRefreshCall) {
      AppLogger.info("Detected 401. Attempting refresh...", tag: _tag);

      try {
        final newToken = await _handleTokenRefresh();
        if (newToken != null) {
          final retryResponse =
              await _retryRequest(err.requestOptions, newToken);
          return handler.resolve(retryResponse);
        } else {
          AppLogger.error("Refresh failed, logging out.", tag: _tag);
          await _handleLogout();
          return handler.next(err);
        }
      } catch (e) {
        AppLogger.error("Error during token refresh", tag: _tag, error: e);
        await _handleLogout();
        return handler.next(err);
      }
    } else {
      AppLogger.info("Passing error downstream.", tag: _tag);
      return handler.next(err);
    }
  }

  Future<String?> _handleTokenRefresh() async {
    if (_refreshAttempts >= _maxRefreshAttempts) {
      AppLogger.error("Max refresh attempts reached. Logging out.", tag: _tag);
      return null;
    }

    if (_isRefreshing && _refreshCompleter != null) {
      AppLogger.info("Refresh already in progress, waiting...", tag: _tag);
      return await _refreshCompleter!.future;
    }

    _isRefreshing = true;
    _refreshCompleter = Completer<String?>();
    _refreshAttempts++;

    try {
      AppLogger.info("Starting token refresh (attempt $_refreshAttempts)",
          tag: _tag);

      final refreshToken = await _authService.getValidRefreshToken();
      if (refreshToken == null) {
        AppLogger.error("No valid refresh token found.", tag: _tag);
        _refreshCompleter!.complete(null);
        return null;
      }

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

      AppLogger.info("Refresh response received", tag: _tag);

      final tokens = VerifySmsResponseModel.fromJson(refreshResponse.data);

      await _authService.saveTokens(
        accessToken: tokens.accessToken,
        refreshToken: tokens.refreshToken,
      );

      AppLogger.info("New tokens saved successfully", tag: _tag);

      _refreshAttempts = 0;

      _refreshCompleter!.complete(tokens.accessToken);
      return tokens.accessToken;
    } catch (e) {
      AppLogger.error("Refresh failed", tag: _tag, error: e);

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

  Future<Response> _retryRequest(
      RequestOptions requestOptions, String newToken) async {
    AppLogger.info("Retrying original request: ${requestOptions.path}",
        tag: _tag);

    final newHeaders = Map<String, dynamic>.from(requestOptions.headers);
    newHeaders['Authorization'] = 'Bearer $newToken';

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

    return await _dio.request(
      requestOptions.path,
      options: newOptions,
      data: requestOptions.data,
      queryParameters: requestOptions.queryParameters,
    );
  }

  void reset() {
    _refreshAttempts = 0;
    _isRefreshing = false;
    _refreshCompleter?.complete(null);
    _refreshCompleter = null;
  }

  Future<void> _handleLogout() async {
    AppLogger.info("Handling logout", tag: _tag);
    reset();
    await _authService.clearTokens();
  }
}
