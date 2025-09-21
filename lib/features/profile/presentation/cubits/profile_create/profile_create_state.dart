part of 'profile_create_cubit.dart';

@freezed
abstract class ProfileCreateState with _$ProfileCreateState {
  const factory ProfileCreateState({
    @Default('') String name,
    @Default('') String surname,
    @Default('') String email,
    String? nameError,
    String? surnameError,
    String? emailError,
    XFile? image,
  }) = _ProfileCreateState;
}
