import 'package:neighbours/core/domain/entities/user_location/user_location_entity.dart';

abstract class UserLocationRepository {
  Future<UserLocationEntity?> getSaved();

  Future<void> save({required double lat, required double lng});
}
