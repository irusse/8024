import 'package:bloc/bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:image_picker/image_picker.dart';
import 'package:neighbours/core/di/injection.dart';
import 'package:neighbours/core/domain/entities/user/user_entity.dart';
import 'package:neighbours/core/services/image_service.dart';

import '../../mixins/user_data_validation_mixin.dart';

part 'edit_profile_cubit.freezed.dart';

part 'edit_profile_state.dart';

class EditProfileCubit extends Cubit<EditProfileState>
    with UserDataValidationMixin {
  late UserEntity _originalUser;

  EditProfileCubit(UserEntity user)
      : _originalUser = user,
        super(EditProfileState(
            firstName: user.firstName,
            avatarUrl: user.avatar,
            email: user.email,
            gender: user.gender,
            lastName: user.lastName,
            birthDate: user.birthDate));

  final _imageService = getIt<ImageService>();

  void updateFirstName(String firstName) {
    emit(state.copyWith(
      firstName: firstName,
      firstNameError: validateName(firstName),
    ));
  }

  void updateLastName(String? lastName) {
    emit(state.copyWith(
      lastName: lastName,
      lastNameError: validateLastName(lastName),
    ));
  }

  void updateEmail(String? email) {
    emit(state.copyWith(
      email: email,
      emailError: validateEmail(email),
    ));
  }

  void updateGender(String? gender) {
    emit(state.copyWith(gender: gender));
  }

  void updateBirthDate(DateTime? birthDate) {
    emit(state.copyWith(birthDate: birthDate));
  }

  void updateAvatarUrl(String? avatarUrl) {
    emit(state.copyWith(avatarUrl: avatarUrl));
  }

  Future<void> pickImageFromGallery() async {
    final XFile? image = await _imageService.pickImage(ImageSource.gallery);

    if (image != null) {
      emit(state.copyWith(newAvatarFile: image));
    }
  }

  void clearSelectedImage() {
    emit(state.copyWith(newAvatarFile: null));
  }

  bool validateAllFields() {
    final firstNameError = validateName(state.firstName);
    final lastNameError = validateLastName(state.lastName);
    final emailError = validateEmail(state.email);

    emit(state.copyWith(
      firstNameError: firstNameError,
      lastNameError: lastNameError,
      emailError: emailError,
    ));

    return firstNameError == null &&
        lastNameError == null &&
        emailError == null;
  }

  // Method to clear all errors
  void clearErrors() {
    emit(state.copyWith(
      firstNameError: null,
      lastNameError: null,
      emailError: null,
    ));
  }

  bool hasChanges() {
    return state.firstName != _originalUser.firstName ||
        state.lastName != _originalUser.lastName ||
        state.email != _originalUser.email ||
        state.gender != _originalUser.gender ||
        state.avatarUrl != _originalUser.avatar ||
        !_isSameDate(state.birthDate, _originalUser.birthDate) ||
        state.newAvatarFile != null;
  }

  bool _isSameDate(DateTime? date1, DateTime? date2) {
    if (date1 == null && date2 == null) return true;
    if (date1 == null || date2 == null) return false;
    return date1.year == date2.year &&
        date1.month == date2.month &&
        date1.day == date2.day;
  }

  void resetOriginalUser(UserEntity user) {
    _originalUser = user;
    emit(state.copyWith(newAvatarFile: null, avatarUrl: user.avatar));
  }
}
