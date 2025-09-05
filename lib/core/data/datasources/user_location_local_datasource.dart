import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:injectable/injectable.dart';
import 'package:neighbours/core/data/models/user_location/user_location_model.dart';

abstract class UserLocationLocalDataSource {
  Future<void> saveLocation({
    required double lat,
    required double lng,
  });

  Future<UserLocationModel?> getLocation();
}

@Singleton(as: UserLocationLocalDataSource)
class UserLocationLocalDataSourceImpl implements UserLocationLocalDataSource {
  static const _key = 'user_location_v1';

  final FlutterSecureStorage _storage;

  UserLocationLocalDataSourceImpl(this._storage);

  @override
  Future<UserLocationModel?> getLocation() async {
    final raw = await _storage.read(key: _key);
    if (raw == null) return null;
    try {
      final map = jsonDecode(raw) as Map<String, dynamic>;
      return UserLocationModel.fromJson(map);
    } catch (_) {
      await _storage.delete(key: _key);
      return null;
    }
  }

  @override
  Future<void> saveLocation({
    required double lat,
    required double lng,
  }) async {
    final data = UserLocationModel(
      lng: lng,
      lat: lat,
    );
    await _storage.write(key: _key, value: jsonEncode(data.toJson()));
  }
}
