import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';
import 'package:neighbours/core/components/my_location_btn.dart';
import 'package:neighbours/core/cubits/theme/theme_cubit.dart';
import 'package:neighbours/core/extensions/context_ext.dart';
import 'package:neighbours/core/services/map_service.dart';
import 'package:neighbours/core/utils/map_camera_utils.dart';

import '../cubits/user_location/user_location_cubit.dart';

class CenteredMapPicker extends StatefulWidget {
  final Widget centralWidget;
  final ValueChanged<Point> onCameraChange;
  final LatLng? initialCoordinates;
  final ValueChanged<LatLng>? onReset;

  const CenteredMapPicker(
      {super.key,
      required this.centralWidget,
      required this.onCameraChange,
      this.initialCoordinates,
      this.onReset});

  @override
  State<CenteredMapPicker> createState() => _CenteredMapPickerState();
}

class _CenteredMapPickerState extends State<CenteredMapPicker> {
  MapboxMap? _mapController;
  late CameraOptions _initialCamera;
  bool _ready = false;

  @override
  void initState() {
    super.initState();
    _initialCamera = MapCameraUtils.defaultCameraOptions();
    _prepareInitialCamera();
  }

  Future<void> _prepareInitialCamera() async {
    LatLng? target = widget.initialCoordinates;

    if (target == null) {
      final position = await context.read<UserLocationCubit>().getPosition();
      if (position != null) {
        target = LatLng(position.latitude, position.longitude);
      }
    }
    if (target != null) {
      _initialCamera = MapCameraUtils.createCameraOptions(
          lat: target.latitude, lng: target.longitude);
    }
    setState(() => _ready = true);
  }

  Future<void> _flyToCoords(LatLng coordinates) async {
    if (_mapController == null) return;
    await MapCameraUtils.flyToPosition(
      _mapController!,
      coordinates.latitude,
      coordinates.longitude,
    );
  }

  Future<void> _flyToUser() async {
    final position = await context.read<UserLocationCubit>().getPosition();
    if (position != null) {
      await _flyToCoords(LatLng(position.latitude, position.longitude));
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_ready) {
      // пока ждём целевую точку — не монтируем карту, чтобы избежать "скачка"
      return Center(
          child: CircularProgressIndicator(
        color: context.color.primary,
      ));
    }
    return Stack(
      children: [
        MapWidget(
          cameraOptions: _initialCamera,
          styleUri: context.read<ThemeCubit>().getThemeMap,
          onMapCreated: (controller) async {
            _mapController = controller;

            controller
              ..scaleBar.updateSettings(ScaleBarSettings(enabled: false))
              ..compass.updateSettings(CompassSettings(enabled: false))
              ..logo.updateSettings(LogoSettings(enabled: false))
              ..location
                  .updateSettings(LocationComponentSettings(enabled: true));
            final camera = await controller.getCameraState();
            widget.onCameraChange(camera.center);
          },
          onCameraChangeListener: (eventData) {
            widget.onCameraChange(eventData.cameraState.center);
          },
          mapOptions: MapOptions(pixelRatio: 1),
        ),
        widget.centralWidget,
        MyLocationBtn(
          onClick: _flyToUser,
          bottom: 10,
        ),
      ],
    );
  }
}
