import 'package:flutter/cupertino.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';

class MapCameraUtils {
  static const double defaultZoom = 17;
  static const int defaultMapAnimationDuration = 450;

  static CameraOptions createCameraOptions(
      {required double lat, required double lng, double zoom = defaultZoom}) {
    return CameraOptions(
        zoom: zoom, center: Point(coordinates: Position(lng, lat)));
  }

  static CameraOptions defaultCameraOptions() {
    return CameraOptions(
        zoom: defaultZoom,
        center: Point(coordinates: Position(105.3188, 61.5240)));
  }

  static Future<void> zoomToCluster(MapboxMap map, double lat, double lng,
      {double zoomDelta = 2.0}) async {
    final zoom = (await map.getCameraState()).zoom;
    await map.easeTo(
      createCameraOptions(
        lat: lat,
        lng: lng,
        zoom: zoom + zoomDelta,
      ),
      MapAnimationOptions(duration: 1000),
    );
  }

  static Future<void> flyToPosition(MapboxMap map, double lat, double lng,
      {double zoom = defaultZoom}) async {
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await map.flyTo(
        createCameraOptions(
          lat: lat,
          lng: lng,
          zoom: zoom,
        ),
        MapAnimationOptions(duration: defaultMapAnimationDuration),
      );
    });
  }
}
