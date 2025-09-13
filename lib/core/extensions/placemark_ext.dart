import 'package:geocoding/geocoding.dart';

extension PlacemarkFormat on Placemark {
  String get title {
    final parts = [
      street,
      subThoroughfare,
    ].where((e) => e != null && e.isNotEmpty).toList();

    return parts.isNotEmpty ? parts.join(', ') : 'Адрес не найден';
  }

  String get subtitle {
    final parts = [
      country,
      administrativeArea,
    ].where((e) => e != null && e.isNotEmpty).toList();

    return parts.isNotEmpty ? parts.join(' / ') : '';
  }

}
