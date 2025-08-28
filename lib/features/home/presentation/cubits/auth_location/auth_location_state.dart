part of 'auth_location_cubit.dart';

@freezed
class AuthLocationState with _$AuthLocationState {
  const factory AuthLocationState.initial() = _Initial;

  const factory AuthLocationState.sending() = _Sending;

  const factory AuthLocationState.sendSuccess(
      LatLng location, Placemark placeMark) = _SendSuccess;

  const factory AuthLocationState.sendError(String message) = _SendError;
}
