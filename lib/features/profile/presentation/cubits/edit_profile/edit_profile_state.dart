part of 'edit_profile_cubit.dart';

@freezed
abstract class EditProfileState with _$EditProfileState {
  const factory EditProfileState({
    required String firstName,
    String? lastName,
    String? email,
    String? gender,
    String? avatarUrl,
    DateTime? birthDate,
    XFile? newAvatarFile,
    String? firstNameError,
    String? lastNameError,
    String? emailError,
  }) = _EditProfileState;
}