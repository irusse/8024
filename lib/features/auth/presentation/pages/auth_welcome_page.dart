import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:neighbours/core/components/custom_gap.dart';
import 'package:neighbours/core/components/custom_outlined_button.dart';
import 'package:neighbours/core/extensions/context_ext.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';

import '../../../../core/di/injection.dart';
import '../../../../core/router/app_routes.dart';
import '../../../../core/services/map_service.dart';

class AuthWelcomePage extends StatefulWidget {
  const AuthWelcomePage({super.key});

  @override
  State<AuthWelcomePage> createState() => _AuthWelcomePageState();
}

class _AuthWelcomePageState extends State<AuthWelcomePage> {
  MapboxMap? _mapboxMapController;

  @override
  void dispose() {
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    final mapService = getIt<MapService>();
    mapService.initialize();
  }

  void _onMapCreated(MapboxMap mapboxMap) {
    _mapboxMapController = mapboxMap;

    _mapboxMapController
      ?..scaleBar.updateSettings(ScaleBarSettings(enabled: false))
      ..compass.updateSettings(CompassSettings(enabled: false))
      ..logo.updateSettings(LogoSettings(enabled: false));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: MapWidget(
              key: const ValueKey("mapWidget"),
              cameraOptions: CameraOptions(
                zoom: 3.5,
                pitch: 0,
                bearing: 0,
                center: Point(
                    coordinates: Position(
                  97.0,
                  61.0,
                )),
              ),
              mapOptions: MapOptions(
                  pixelRatio: 1,
                  constrainMode: ConstrainMode.NONE,
                  contextMode: ContextMode.UNIQUE,
                  viewportMode: ViewportMode.DEFAULT,
                  crossSourceCollisions: false,
                  orientation: NorthOrientation.UPWARDS,
                  glyphsRasterizationOptions: GlyphsRasterizationOptions(
                    rasterizationMode:
                        GlyphsRasterizationMode.IDEOGRAPHS_RASTERIZED_LOCALLY,
                  )),
              styleUri: MapboxStyles.SATELLITE,
              onMapCreated: _onMapCreated,
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
                height: MediaQuery.of(context).size.height / 3,
                decoration: BoxDecoration(
                  color: context.color.background,
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(20),
                  ),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: SingleChildScrollView(
                    child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const VerticalGap(16),
                    Text(
                      'Здравствуйте,\nдавайте начнём!',
                      style: context.text.titleLarge
                          .copyWith(fontWeight: FontWeight.w500),
                      textAlign: TextAlign.center,
                    ),
                    const VerticalGap(24),
                    CustomOutlinedButton(
                      onPressed: () => context.go(AppRoutePath.login),
                      text: 'Войти',
                      verticalPadding: 14,
                    ),
                    const VerticalGap(16),
                    Text.rich(
                      TextSpan(
                          text:
                              'Продолжая вход в приложение, вы соглашаетесь\nс ',
                          children: [
                            TextSpan(
                              text: 'Политикой конфиденциальности',
                              style: TextStyle(
                                  decoration: TextDecoration.underline,
                                  decorationColor:
                                      context.color.primaryText,
                                  color: context.color.primaryText),
                            ),
                            const TextSpan(text: ' и '),
                            TextSpan(
                              text: 'Условиями\nиспользования сервиса',
                              style: TextStyle(
                                  decoration: TextDecoration.underline,
                                  decorationColor:
                                      context.color.primaryText,
                                  color: context.color.primaryText),
                            ),
                            const TextSpan(text: ' Местные'),
                          ],
                          style: context.text.bodySmall.copyWith(
                              color: context.color.secondaryText)),
                      textAlign: TextAlign.center,
                    ),
                    const VerticalGap(16),
                  ],
                ))),
          ),
        ],
      ),
    );
  }
}
