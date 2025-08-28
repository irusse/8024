part of 'profile_cubit.dart';



@freezed
class ProfileState with _$ProfileState {
  const factory ProfileState.initial() = ProfileInitial;
  const factory ProfileState.logoutLoading() = ProfileLogoutLoading;
  const factory ProfileState.logoutSuccess() = ProfileLogoutSuccess;
  const factory ProfileState.error(String message) = ProfileError;
}
