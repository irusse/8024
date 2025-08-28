import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';
import 'package:neighbours/core/components/my_location_btn.dart';
import 'package:neighbours/core/cubits/theme/theme_cubit.dart';
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

  Future<void> _flyToCoords(LatLng coordinates) async {
    if (_mapController == null) return;
    await MapCameraUtils.flyToPosition(
        _mapController!, Position(coordinates.longitude, coordinates.latitude));
  }

  Future<void> _flyToUser() async {
    final position = await context.read<UserLocationCubit>().getPosition();
    if (position != null) {
      await _flyToCoords(LatLng(position.latitude, position.longitude));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        MapWidget(
          styleUri: context.read<ThemeCubit>().getThemeMap,
          onMapCreated: (controller) async {
            _mapController = controller;

            controller
              ..scaleBar.updateSettings(ScaleBarSettings(enabled: false))
              ..compass.updateSettings(CompassSettings(enabled: false))
              ..logo.updateSettings(LogoSettings(enabled: false))
              ..location
                  .updateSettings(LocationComponentSettings(enabled: true));

            // Когда карта загрузилась — проверяем initialCoordinates
            if (widget.initialCoordinates != null) {
              await _flyToCoords(widget.initialCoordinates!);
              // Сразу сообщим наружу точное положение (без дрожания анимации)
              widget.onCameraChange(
                Point(
                  coordinates: Position(
                    widget.initialCoordinates!.longitude,
                    widget.initialCoordinates!.latitude,
                  ),
                ),
              );
            } else {
              await _flyToUser();
            }
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
