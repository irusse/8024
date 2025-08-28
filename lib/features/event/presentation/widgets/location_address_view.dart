import 'package:flutter/material.dart';
import 'package:neighbours/core/extensions/context_ext.dart';
import 'package:neighbours/core/extensions/placemark_ext.dart';

import '../../../../core/components/icon_text_span.dart';
import '../../../../core/constants/assets.dart';
import '../../../../core/di/injection.dart';
import '../../../../core/services/map_service.dart';

class LocationAddressView extends StatefulWidget {
  final double latitude;
  final double longitude;
  final int maxLines;

  const LocationAddressView(
      {super.key,
      required this.latitude,
      required this.longitude,
      this.maxLines = 2});

  @override
  State<LocationAddressView> createState() => _LocationAddressViewState();
}

class _LocationAddressViewState extends State<LocationAddressView> {
  final ValueNotifier<String?> _addressNotifier = ValueNotifier(null);
  final mapService = getIt<MapService>();

  @override
  void initState() {
    super.initState();
    _loadAddress();
  }

  Future<void> _loadAddress() async {
    final placemark = await mapService.getPlacemarkFromCoordinates(
      LatLng(widget.latitude, widget.longitude),
    );

    _addressNotifier.value = placemark?.title;
  }

  @override
  void dispose() {
    _addressNotifier.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<String?>(
      valueListenable: _addressNotifier,
      builder: (context, address, _) {
        if (address == null) {
          return const SizedBox.shrink();
        } else {
          return Center(
              child: IconTextSpan(
            text: address,
            textStyle: context.text.bodyLarge,
            iconColor: context.color.primaryText,
            iconPath: Assets.icons.location,
            maxLines: widget.maxLines,
            spacing: 8,
          ));
        }
      },
    );
  }
}
