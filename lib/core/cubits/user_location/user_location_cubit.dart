import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:injectable/injectable.dart';
import 'package:neighbours/core/domain/repositories/user_location_repository.dart';
import 'package:neighbours/core/services/map_service.dart';

part 'user_location_cubit.freezed.dart';

part 'user_location_state.dart';

@singleton
class UserLocationCubit extends Cubit<UserLocationState> {
  final UserLocationRepository _userLocationRepository;
  final MapService _mapService;

  UserLocationCubit(this._userLocationRepository, this._mapService)
      : super(const UserLocationState.initial());

  Future<LatLng?> getPosition() async {
    final hasPermission = await _hasPermission();
    if (!hasPermission) return null;

    try {
      emit(const UserLocationState.loading());

      const LocationSettings locationSettings = LocationSettings(
          accuracy: LocationAccuracy.high,
          distanceFilter: 10,
          timeLimit: Duration(seconds: 5));

      Position position = await Geolocator.getCurrentPosition(
          locationSettings: locationSettings);

      final coordinates = LatLng(position.latitude, position.longitude);
      await _updateUserLocation(coordinates);

      return coordinates;
    } on TimeoutException {
      return null;
    } on LocationServiceDisabledException {
      _serviceDisabled();
      return null;
    } catch (e) {
      emit(const UserLocationState.failedToResolvePlacemark());
      return null;
    }
  }

  Future<LatLng?> fetchLocalLocation() async {
    final res = await _userLocationRepository.getSaved();
    if (res == null) return null;
    final coords = LatLng(res.lat, res.lng);
    _updateUserLocation(coords);
    return coords;
  }

  Future<void> _updateUserLocation(
    LatLng coordinates, {
    Placemark? placemark,
  }) async {
    final resolvedPlacemark =
        placemark ?? await _mapService.getPlacemarkFromCoordinates(coordinates);
    if (resolvedPlacemark == null) {
      emit(const UserLocationState.failedToResolvePlacemark());
      return;
    }
    await _userLocationRepository.save(
      lat: coordinates.latitude,
      lng: coordinates.longitude,
    );
    emit(UserLocationState.locationReceived(
      coordinates: coordinates,
      placemark: resolvedPlacemark,
    ));
  }

  void _serviceDisabled() {
    emit(const UserLocationState.initial());
    emit(const UserLocationState.serviceDisabled());
  }

  void _permissionDeniedForever() {
    emit(const UserLocationState.initial());
    emit(const UserLocationState.permissionDeniedForever());
  }

  void _permissionDenied() {
    emit(const UserLocationState.initial());
    emit(const UserLocationState.permissionDenied());
  }

  Future<bool> _hasPermission() async {
    LocationPermission permission = await Geolocator.checkPermission();

    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        _permissionDenied();
        return false;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      _permissionDeniedForever();
      return false;
    }

    return true;
  }

  void openLocationSettings() async {
    await Geolocator.openLocationSettings();
  }

  void openSettings() async {
    await Geolocator.openAppSettings();
  }
}
