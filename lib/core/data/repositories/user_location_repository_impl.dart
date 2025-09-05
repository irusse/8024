import 'package:injectable/injectable.dart';
import 'package:neighbours/core/data/datasources/user_location_local_datasource.dart';
import 'package:neighbours/core/domain/entities/user_location/user_location_entity.dart';
import 'package:neighbours/core/domain/repositories/user_location_repository.dart';

@LazySingleton(as: UserLocationRepository)
class UserLocationRepositoryImpl implements UserLocationRepository {
  final UserLocationLocalDataSource _local;

  UserLocationRepositoryImpl(this._local);

  @override
  Future<UserLocationEntity?> getSaved() async {
    final model = await _local.getLocation();
    return model?.toEntity();
  }

  @override
  Future<void> save({
    required double lat,
    required double lng,
  }) async {
    await _local.saveLocation(
      lat: lat,
      lng: lng,
    );
  }
}
