import 'package:flutter/cupertino.dart';
import 'package:geocoding/geocoding.dart';
import 'package:injectable/injectable.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';

import '../config/app_config.dart';

class LatLng {
  final double latitude;
  final double longitude;

  @override
  String toString() {
    return '(latitude: $latitude, longitude: $longitude)';
  }

  const LatLng(this.latitude, this.longitude);
}

abstract class MapService {
  void initialize();

  Future<Placemark?> getPlacemarkFromCoordinates(LatLng coordinates) async {
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(
        coordinates.latitude,
        coordinates.longitude,
      );

      if (placemarks.isNotEmpty) {
        return placemarks.first;
      }
      return null;
    } catch (e) {
      debugPrint('Ошибка геокодирования: $e');
      return null;
    }
  }
}

@LazySingleton(as: MapService)
class MapboxService extends MapService {
  MapboxService();

  final accessToken = AppConfig.mapBoxToken;

  @override
  void initialize() {
    MapboxOptions.setAccessToken(accessToken);
  }
}
