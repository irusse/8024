import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';
import 'package:neighbours/core/cubits/theme/theme_cubit.dart';

class HomeMapView extends StatelessWidget {
  const HomeMapView({
    super.key,
    required this.onMapCreated,
    required this.onStyleLoadedListener,
    this.onMapTap,
    this.initialCameraOptions,
  });

  final Function(MapboxMap) onMapCreated;
  final Function(MapContentGestureContext)? onMapTap;
  final Function(StyleLoadedEventData)? onStyleLoadedListener;
  final CameraOptions? initialCameraOptions;

  @override
  Widget build(BuildContext context) {
    return MapWidget(
      cameraOptions: initialCameraOptions,
      styleUri: context.read<ThemeCubit>().getThemeMap,
      onMapCreated: (controller) {
        controller
          ..scaleBar.updateSettings(ScaleBarSettings(enabled: false))
          ..compass.updateSettings(CompassSettings(enabled: false))
          ..logo.updateSettings(LogoSettings(enabled: false))
          ..location.updateSettings(LocationComponentSettings(enabled: true));
        onMapCreated(controller);
      },
      onStyleLoadedListener: onStyleLoadedListener,
      onTapListener: onMapTap,
      mapOptions: MapOptions(
        pixelRatio: MediaQuery.of(context).devicePixelRatio,
      ),
    );
  }
}
