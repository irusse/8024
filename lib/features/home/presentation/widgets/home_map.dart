import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';
import 'package:neighbours/core/components/bottom_sheet_dialog.dart';
import 'package:neighbours/core/components/get_location_dialog.dart';
import 'package:neighbours/core/cubits/theme/theme_cubit.dart';
import 'package:neighbours/core/cubits/user_location/user_location_cubit.dart';
import 'package:neighbours/core/utils/map_camera_utils.dart';

class HomeMapView extends StatelessWidget {
  const HomeMapView({
    super.key,
    required this.onMapCreated,
    required this.onStyleLoadedListener,
    required this.mapboxMapController,
    this.onMapTap,
    this.initialCameraOptions,
  });

  final Function(MapboxMap) onMapCreated;
  final MapboxMap? mapboxMapController;
  final Function(MapContentGestureContext)? onMapTap;
  final Function(StyleLoadedEventData)? onStyleLoadedListener;
  final CameraOptions? initialCameraOptions;

  void _showLocationDisabledDialog(BuildContext context) async {
    await showBaseBottomSheet(
        context: context,
        title: 'Где вы находитесь',
        child: BlocProvider.value(
          value: context.read<UserLocationCubit>(),
          child: const GetLocationDialog(),
        ));
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<UserLocationCubit, UserLocationState>(
        listener: (context, locationState) {
          locationState.maybeWhen(
              permissionDenied: () => _showLocationDisabledDialog(context),
              permissionDeniedForever: () =>
                  _showLocationDisabledDialog(context),
              orElse: () {},
              locationReceived: (coordinates, _) {
                MapCameraUtils.flyToPosition(
                  mapboxMapController!,
                  coordinates.latitude,
                  coordinates.longitude,
                );
              });
        },
        child: MapWidget(
          cameraOptions: initialCameraOptions,
          styleUri: context.read<ThemeCubit>().getThemeMap,
          onMapCreated: (controller) {
            controller
              ..scaleBar.updateSettings(ScaleBarSettings(enabled: false))
              ..compass.updateSettings(CompassSettings(enabled: false))
              ..logo.updateSettings(LogoSettings(enabled: false))
              ..location
                  .updateSettings(LocationComponentSettings(enabled: true));
            onMapCreated(controller);
          },
          onStyleLoadedListener: onStyleLoadedListener,
          onTapListener: onMapTap,
          mapOptions: MapOptions(
            pixelRatio: MediaQuery.of(context).devicePixelRatio,
          ),
        ));
  }
}
