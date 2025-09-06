import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:injectable/injectable.dart';

abstract class PushLocalDataSource {
  /// Сохранить FCM токен в локальное хранилище
  Future<void> saveFcmToken(String fcmToken);

  /// Получить FCM токен из локального хранилища
  Future<String?> getFcmToken();

  /// Удалить FCM токен из локального хранилища
  Future<void> removeFcmToken();
}

@Singleton(as: PushLocalDataSource)
class PushLocalDataSourceImpl implements PushLocalDataSource {
  static const _fcmTokenKey = 'fcm_token_v1';

  final FlutterSecureStorage _storage;

  PushLocalDataSourceImpl(this._storage);

  @override
  Future<void> saveFcmToken(String fcmToken) async {
    await _storage.write(key: _fcmTokenKey, value: fcmToken);
  }

  @override
  Future<String?> getFcmToken() async {
    return await _storage.read(key: _fcmTokenKey);
  }

  @override
  Future<void> removeFcmToken() async {
    await _storage.delete(key: _fcmTokenKey);
  }
}
