import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';
import 'package:neighbours/core/components/default_loading_overlay.dart';
import 'package:neighbours/core/components/floating_app_bar.dart';
import 'package:neighbours/core/components/primary_button.dart';
import 'package:neighbours/core/services/map_service.dart';

import '../cubits/theme/theme_cubit.dart';
import '../cubits/user_location/user_location_cubit.dart';
import '../utils/map_camera_utils.dart';
import 'my_location_btn.dart';

class FullScreenMapPicker extends StatefulWidget {
  final Widget centralWidget;
  final ValueChanged<Point> onCameraChange;
  final LatLng? initialCoordinates;
  final String title;

  const FullScreenMapPicker({
    super.key,
    required this.centralWidget,
    required this.onCameraChange,
    this.initialCoordinates,
    this.title = 'Выберите точку на карте',
  });

  @override
  State<FullScreenMapPicker> createState() => _FullScreenMapPickerState();
}

class _FullScreenMapPickerState extends State<FullScreenMapPicker> {
  MapboxMap? _mapController;
  late CameraOptions _initialCamera;
  bool _ready = false;
  Point? _currentCenter;

  @override
  void initState() {
    super.initState();
    _initialCamera = MapCameraUtils.defaultCameraOptions();
    _prepareInitialCamera();
  }

  Future<void> _prepareInitialCamera() async {
    LatLng? target = widget.initialCoordinates;
    _initialCamera = MapCameraUtils.defaultCameraOptions();
    final userLocationCubit = context.read<UserLocationCubit>();
    if (target == null) {
      // Получаем координаты пользователя
      final position = await userLocationCubit.getPosition();
      if (position != null) {
        target = LatLng(position.latitude, position.longitude);
      } else {
        // Если не удадлось получить то берем из кэша
        target = await userLocationCubit.fetchLocalLocation();
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

  void _onConfirm() {
    if (_currentCenter != null) {
      context.pop(_currentCenter);
    }
  }

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    return Scaffold(
        body: !_ready
            ? DefaultLoadingOverlay()
            : Stack(
                children: [
                  MapWidget(
                    cameraOptions: _initialCamera,
                    styleUri: context.read<ThemeCubit>().getThemeMap,
                    onMapCreated: (controller) async {
                      _mapController = controller;

                      controller
                        ..scaleBar
                            .updateSettings(ScaleBarSettings(enabled: false))
                        ..compass
                            .updateSettings(CompassSettings(enabled: false))
                        ..logo.updateSettings(LogoSettings(enabled: false))
                        ..location.updateSettings(
                            LocationComponentSettings(enabled: true));
                      final camera = await controller.getCameraState();
                      setState(() => _currentCenter = camera.center);
                      widget.onCameraChange(camera.center);
                    },
                    onCameraChangeListener: (eventData) {
                      setState(
                          () => _currentCenter = eventData.cameraState.center);
                      widget.onCameraChange(eventData.cameraState.center);
                    },
                    mapOptions: MapOptions(pixelRatio: 1),
                  ),
                  Align(
                    alignment: Alignment.center,
                    child: widget.centralWidget,
                  ),
                  Positioned(
                    top: 0,
                    left: 0,
                    right: 0,
                    child: FloatingAppBar(
                      title: widget.title,
                    ),
                  ),
                  Positioned(
                    bottom: 16,
                    left: 16,
                    right: 16,
                    child: PrimaryButton(
                      text: 'Подтвердить',
                      onPressed: _onConfirm,
                    ),
                  ),
                  MyLocationBtn(
                    onClick: _flyToUser,
                    bottom: height / 4,
                  ),
                ],
              ));
  }
}
