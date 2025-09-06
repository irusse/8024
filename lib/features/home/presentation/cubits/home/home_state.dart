part of 'home_cubit.dart';

sealed class HomeState {
  const HomeState();
}

class Idle extends HomeState {
  const Idle();
}

class Loading extends HomeState {
  const Loading();
}

class ShowAddressStep extends HomeState {
  const ShowAddressStep();
}

class ShowUserInfoStep extends HomeState {
  const ShowUserInfoStep();
}

class ShowAddPropertyStep extends HomeState {
  const ShowAddPropertyStep({this.initialCoordinates});

  final LatLng? initialCoordinates;
}

class ShowNoActiveCommunities extends HomeState {
  const ShowNoActiveCommunities();
}

class Error extends HomeState {
  const Error({required this.message});

  final String message;
}

class NetworkError extends HomeState {
  const NetworkError({required this.message});

  final String message;
}

class GetStepError extends HomeState {
  const GetStepError({required this.message});

  final String message;
}

class ShowSetCoordinates extends HomeState {
  const ShowSetCoordinates();
}

class ShowAddEvent extends HomeState {
  const ShowAddEvent();
}
