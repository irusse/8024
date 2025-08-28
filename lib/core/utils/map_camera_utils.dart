import 'package:flutter/cupertino.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';

class MapCameraUtils {
  static Future<void> zoomToCluster(MapboxMap map, double lat, double lng,
      {double zoomDelta = 2.0}) async {
    final zoom = (await map.getCameraState()).zoom;
    await map.easeTo(
      CameraOptions(
        center: Point(coordinates: Position(lng, lat)),
        zoom: zoom + zoomDelta,
      ),
      MapAnimationOptions(duration: 1000),
    );
  }

  static Future<void> flyToPosition(MapboxMap map, Position pos,
      {double zoom = 17}) async {
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await map.flyTo(
        CameraOptions(center: Point(coordinates: pos), zoom: zoom),
        MapAnimationOptions(),
      );
    });
  }
}
