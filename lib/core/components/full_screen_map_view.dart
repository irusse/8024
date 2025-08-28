import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';
import 'package:neighbours/core/components/default_app_bar.dart';
import 'package:neighbours/core/cubits/theme/theme_cubit.dart';
import 'package:neighbours/core/extensions/context_ext.dart';
import 'package:neighbours/core/services/marker_service.dart';
import 'package:neighbours/core/di/injection.dart';

class FullScreenMapView extends StatefulWidget {
  final double latitude;
  final double longitude;

  const FullScreenMapView({
    super.key,
    required this.latitude,
    required this.longitude,
  });

  @override
  State<FullScreenMapView> createState() => _FullScreenMapViewState();
}

class _FullScreenMapViewState extends State<FullScreenMapView> {
  PointAnnotationManager? _annotationManager;

  @override
  void dispose() {
    _annotationManager?.deleteAll();
    super.dispose();
  }

  void _onMapCreated(MapboxMap mapboxMap) async {
    final markerColor = context.color.primary;

    // Отключаем UI элементы Mapbox
    mapboxMap
      ..scaleBar.updateSettings(ScaleBarSettings(enabled: false))
      ..compass.updateSettings(CompassSettings(enabled: false))
      ..logo.updateSettings(LogoSettings(enabled: false));

    // Загружаем кастомный маркер
    Uint8List markerImage = await getIt<MarkerService>().createSimpleMarker(
      options: EmptyCircleOptions(
        color: markerColor,
        size: 80,
      ),
    );

    // Создаём аннотацию
    final manager = await mapboxMap.annotations.createPointAnnotationManager();
    _annotationManager = manager;

    await manager.create(PointAnnotationOptions(
      geometry: Point(
        coordinates: Position(widget.longitude, widget.latitude),
      ),
      image: markerImage,
      iconSize: 1.0,
    ));

    // Перемещаем камеру к точке
    await mapboxMap.setCamera(
      CameraOptions(
        center: Point(
          coordinates: Position(widget.longitude, widget.latitude),
        ),
        zoom: 15,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const DefaultAppBar(showBackButton: true),
      body: MapWidget(
        onMapCreated: _onMapCreated,
        cameraOptions: CameraOptions(
          center: Point(
            coordinates: Position(widget.longitude, widget.latitude),
          ),
          zoom: 15,
        ),
        styleUri: context.read<ThemeCubit>().getThemeMap,
      ),
    );
  }
}
