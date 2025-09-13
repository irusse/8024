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
    @Default(false) bool isSubmitting,
    @Default(false) bool isSubmittedSuccessfully,
    String? submitError,
    XFile? image,
  }) = _ProfileCreateState;
}
