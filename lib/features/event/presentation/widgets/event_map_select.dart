import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';
import '../../../../core/cubits/user_location/user_location_cubit.dart';

class EventMapSelect extends StatelessWidget {
  final ValueChanged<Point> onCameraChange;

  const EventMapSelect({super.key, required this.onCameraChange});

  void _onMapCreated(BuildContext context, MapboxMap mapboxMap) async {
    final position = await context.read<UserLocationCubit>().getPosition();
    if (position == null) return;

    await mapboxMap.flyTo(
      CameraOptions(
        center: Point(
          coordinates: Position(position.longitude, position.latitude),
        ),
        zoom: 15.0,
      ),
      MapAnimationOptions(
        duration: 1000,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 1.2,
      child: Stack(
        children: [
          MapWidget(
            styleUri: 'mapbox://styles/mapbox/navigation-night-v1',
            onMapCreated: (controller) {
              controller
                ..scaleBar.updateSettings(ScaleBarSettings(enabled: false))
                ..compass.updateSettings(CompassSettings(enabled: false))
                ..logo.updateSettings(LogoSettings(enabled: false));

              _onMapCreated(context, controller);
            },
            onCameraChangeListener: (eventData) {
              onCameraChange(eventData.cameraState.center);
            },
            mapOptions: MapOptions(pixelRatio: 1),
          ),

        ],
      ),
    );
  }
}
