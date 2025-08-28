part of 'user_location_cubit.dart';

@freezed
class UserLocationState with _$UserLocationState {
  const factory UserLocationState.initial() = _Initial;

  const factory UserLocationState.loading() = _Loading;

  const factory UserLocationState.locationReceived({
    required LatLng coordinates,
    required Placemark placemark,
  }) = _LocationReceived;

  const factory UserLocationState.permissionDenied() = _PermissionDenied;
  const factory UserLocationState.permissionDeniedForever() = _PermissionDeniedForever;
  const factory UserLocationState.serviceDisabled() = _ServiceDisabled;
  const factory UserLocationState.failedToResolvePlacemark() = _FailedToResolvePlacemark;
  const factory UserLocationState.error(String message) = _Error;
}

extension UserLocationStateX on UserLocationState {
  bool get isLoading => maybeWhen(
    loading: () => true,
    orElse: () => false,
  );
}