import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';
import 'package:neighbours/core/cubits/theme/theme_cubit.dart';
import 'package:neighbours/core/extensions/context_ext.dart';
import 'package:neighbours/core/router/app_routes.dart';
import 'package:neighbours/core/services/map_service.dart';
import 'package:neighbours/core/services/marker_service.dart';
import 'package:neighbours/core/di/injection.dart';
import 'package:neighbours/core/utils/map_camera_utils.dart';

class MapPreview extends StatefulWidget {
  final double latitude;
  final double longitude;
  final double? radius;
  final double height;

  const MapPreview({
    super.key,
    required this.latitude,
    required this.longitude,
    this.height = 132,
    this.radius,
  });

  @override
  State<MapPreview> createState() => _MapPreviewState();
}

class _MapPreviewState extends State<MapPreview> {
  PointAnnotationManager? _annotationManager;

  @override
  void dispose() {
    _annotationManager?.deleteAll();
    super.dispose();
  }

  void _onMapCreated(MapboxMap mapboxMap) async {
    final primary = context.color.primary;
    mapboxMap
      ..scaleBar.updateSettings(ScaleBarSettings(enabled: false))
      ..compass.updateSettings(CompassSettings(enabled: false))
      ..logo.updateSettings(LogoSettings(enabled: false));

    Uint8List markerImage = await getIt<MarkerService>().createSimpleMarker(
      options: EmptyCircleOptions(
        color: primary,
        size: 80,
      ),
    );

    // Создаём менеджер аннотаций
    final manager = await mapboxMap.annotations.createPointAnnotationManager();
    _annotationManager = manager;

    await manager.create(PointAnnotationOptions(
      geometry: Point(
        coordinates: Position(widget.longitude, widget.latitude),
      ),
      image: markerImage,
      iconSize: 1.0,
    ));
    await MapCameraUtils.flyToPosition(
        mapboxMap, widget.latitude, widget.longitude);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => context.push(AppRoutePath.fullMapPreview,
          extra: LatLng(widget.latitude, widget.longitude)),
      child: SizedBox(
        height: widget.height,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(widget.radius ?? 0),
          child: SizedBox(
            height: widget.height,
            child: Stack(
              children: [
                AbsorbPointer(
                  child: MapWidget(
                    onMapCreated: _onMapCreated,
                    cameraOptions: CameraOptions(
                      center: Point(
                        coordinates:
                            Position(widget.longitude, widget.latitude),
                      ),
                      zoom: 9.0,
                    ),
                    styleUri: context.read<ThemeCubit>().getThemeMap,
                  ),
                ),
                Positioned(
                  right: 10,
                  top: 10,
                  child: Icon(
                    Icons.fullscreen_outlined,
                    color: context.color.primaryText,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
