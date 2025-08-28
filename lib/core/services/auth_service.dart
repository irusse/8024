import 'dart:async';

import 'package:injectable/injectable.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter/cupertino.dart';

@singleton
class AuthService {
  static const _accessTokenKey = 'access_token';
  static const _refreshTokenKey = 'refresh_token';
  final FlutterSecureStorage _storage;

  AuthService(this._storage);

  // Поток оповещений об изменениях accessToken
  final _accessTokenController = StreamController<String?>.broadcast();
  bool _isDisposed = false;

  Stream<String?> get accessTokenStream => _accessTokenController.stream;

  /// Проверяет наличие токена
  Future<bool> hasToken() async {
    try {
      final token = await _storage.read(key: _accessTokenKey);
      return token != null && token.isNotEmpty;
    } catch (e) {
      debugPrint('[AuthService] Error checking token: $e');
      return false;
    }
  }

  /// Сохраняет токены с валидацией
  Future<void> saveTokens({
    required String accessToken,
    required String refreshToken,
  }) async {
    try {
      // Валидация токенов
      if (accessToken.isEmpty || refreshToken.isEmpty) {
        throw ArgumentError('Tokens cannot be empty');
      }

      await Future.wait([
        _storage.write(key: _accessTokenKey, value: accessToken),
        _storage.write(key: _refreshTokenKey, value: refreshToken),
      ]);

      if (!_isDisposed) {
        _accessTokenController.add(accessToken);
        debugPrint('[AuthService] Tokens saved successfully');
      }
    } catch (e) {
      debugPrint('[AuthService] Error saving tokens: $e');
      rethrow;
    }
  }

  /// Очищает токены
  Future<void> clearTokens() async {
    try {
      await Future.wait([
        _storage.delete(key: _accessTokenKey),
        _storage.delete(key: _refreshTokenKey),
      ]);

      if (!_isDisposed) {
        _accessTokenController.add(null);
        debugPrint('[AuthService] Tokens cleared successfully');
      }
    } catch (e) {
      debugPrint('[AuthService] Error clearing tokens: $e');
      // Не пробрасываем ошибку, так как очистка должна быть надежной
    }
  }

  /// Получает access token
  Future<String?> getAccessToken() async {
    try {
      final token = await _storage.read(key: _accessTokenKey);
      return token?.isNotEmpty == true ? token : null;
    } catch (e) {
      debugPrint('[AuthService] Error getting access token: $e');
      return null;
    }
  }

  /// Получает refresh token
  Future<String?> getRefreshToken() async {
    try {
      final token = await _storage.read(key: _refreshTokenKey);
      return token?.isNotEmpty == true ? token : null;
    } catch (e) {
      debugPrint('[AuthService] Error getting refresh token: $e');
      return null;
    }
  }

  /// Проверяет валидность токена (базовая проверка)
  bool isTokenValid(String? token) {
    if (token == null || token.isEmpty) return false;
    
    // Базовая проверка формата JWT (должен содержать 3 части, разделенные точками)
    final parts = token.split('.');
    return parts.length == 3;
  }

  /// Получает валидный access token
  Future<String?> getValidAccessToken() async {
    final token = await getAccessToken();
    return isTokenValid(token) ? token : null;
  }

  /// Получает валидный refresh token
  Future<String?> getValidRefreshToken() async {
    final token = await getRefreshToken();
    return isTokenValid(token) ? token : null;
  }

  /// Проверяет, авторизован ли пользователь
  Future<bool> isAuthenticated() async {
    try {
      final accessToken = await getValidAccessToken();
      final refreshToken = await getValidRefreshToken();
      return accessToken != null && refreshToken != null;
    } catch (e) {
      debugPrint('[AuthService] Error checking authentication: $e');
      return false;
    }
  }

  /// Безопасно освобождает ресурсы
  void dispose() {
    if (!_isDisposed) {
      _isDisposed = true;
      _accessTokenController.close();
      debugPrint('[AuthService] Disposed successfully');
    }
  }

  /// Проверяет, был ли сервис освобожден
  bool get isDisposed => _isDisposed;
}
