import 'package:bloc/bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:injectable/injectable.dart';
import 'package:image_picker/image_picker.dart';
import 'package:neighbours/core/di/injection.dart';
import 'package:neighbours/core/domain/entities/user/user_entity.dart';
import 'package:neighbours/core/services/image_service.dart';

import '../../../../../core/mixins/form_validation_mixin.dart';
import '../../../domain/repositories/home_repository.dart';

part 'profile_create_cubit.freezed.dart';

part 'profile_create_state.dart';

@injectable
class ProfileCreateCubit extends Cubit<ProfileCreateState>
    with FormValidationMixin {
  final HomeRepository _homeRepository;

  ProfileCreateCubit(this._homeRepository) : super(const ProfileCreateState());
  final _imageService = getIt<ImageService>();

  void onNameChanged(String value) {
    final nameError = validateName(value);
    emit(state.copyWith(
      name: value,
      nameError: nameError,
    ));
  }

  void onSurnameChanged(String value) {
    final surnameError = validateLastName(value);
    emit(state.copyWith(
      surname: value,
      surnameError: surnameError,
    ));
  }

  // Method to validate all fields at once
  bool validateAllFields() {
    final firstNameError = validateName(state.name);
    final lastNameError = validateLastName(state.surname);
    final emailError = validateEmail(state.email);

    emit(state.copyWith(
      nameError: firstNameError,
      surnameError: lastNameError,
      emailError: emailError,
    ));

    return firstNameError == null &&
        lastNameError == null &&
        emailError == null;
  }

  void onEmailChanged(String value) {
    final emailError = validateEmail(value);
    emit(state.copyWith(
      email: value,
      emailError: emailError,
    ));
  }

  Future<void> pickImageFromGallery() async {
    final XFile? image = await _imageService.pickImage(ImageSource.gallery);

    if (image != null) {
      emit(state.copyWith(image: image));
    }
  }

  void clearValidationErrors() {
    emit(state.copyWith(
      nameError: null,
      surnameError: null,
      emailError: null,
    ));
  }

  void onImagePicked(XFile? image) {
    emit(state.copyWith(image: image));
  }

  void removeImage() {
    emit(state.copyWith(image: null));
  }

  Future<UserEntity?> submit() async {
    if (!validateAllFields()) return null;

    emit(state.copyWith(
      isSubmitting: true,
      submitError: null,
      isSubmittedSuccessfully: false,
    ));

    final result = await _homeRepository.submitProfile(
      name: state.name,
      surname: state.surname,
      email: state.email,
      image: state.image,
    );

    return result.fold(
      (failure) {
        emit(state.copyWith(
          isSubmitting: false,
          submitError: failure.message,
          isSubmittedSuccessfully: false,
        ));
        return null;
      },
      (user) {
        emit(state.copyWith(
          isSubmitting: false,
          submitError: null,
          isSubmittedSuccessfully: true,
        ));
        return user;
      },
    );
  }
}
