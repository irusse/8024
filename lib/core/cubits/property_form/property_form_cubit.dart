import 'package:bloc/bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:image_picker/image_picker.dart';
import 'package:neighbours/core/di/injection.dart';
import 'package:neighbours/core/domain/entities/property/property_entity.dart';
import 'package:neighbours/core/services/image_service.dart';

import '../../constants/default_constants.dart';
import '../../services/map_service.dart';

part 'property_form_cubit.freezed.dart';

part 'property_form_state.dart';

class PropertyFormCubit extends Cubit<PropertyFormState> {
  PropertyEntity? _originalProperty;

  PropertyFormCubit({PropertyEntity? property})
      : _originalProperty = property,
        super(PropertyFormState(
            photoUrl: property?.photo,
            name: property?.name ?? '',
            latitude: property?.latitude,
            longitude: property?.longitude,
            isVerified:
                property?.verificationStatus ?? DefaultConstants.unverified,
            id: property?.id ?? 0,
            category: property?.category ??
                DefaultConstants.propertyTypeOptions.keys.toList()[0]));

  final _imageService = getIt<ImageService>();

  List<String> get typeApiValues =>
      DefaultConstants.propertyTypeOptions.keys.toList();

  List<String> get typeLabels =>
      DefaultConstants.propertyTypeOptions.values.toList();

  String getLabel(String apiValue) =>
      DefaultConstants.propertyTypeOptions[apiValue]!;

  String getApiTypeByLabel(String label) =>
      DefaultConstants.propertyTypeOptions.entries
          .firstWhere((e) => e.value == label)
          .key;

  void setCategory(String apiType) {
    emit(state.copyWith(category: apiType));
  }

  void setCoordinates(LatLng coordinates) {
    emit(state.copyWith(
        longitude: coordinates.longitude, latitude: coordinates.latitude));
  }

  String? validateName(String name) {
    if (name.trim().isEmpty) {
      return 'Название обязательно для заполнения';
    }
    if (name.trim().length < 3) {
      return 'Название должно содержать минимум 3 символа';
    }
    return null;
  }

  void setName(String name) {
    final nameError = validateName(name);
    emit(state.copyWith(
      name: name,
      nameError: nameError,
    ));
  }

  void resetOriginalProperty(PropertyEntity property) {
    _originalProperty = property;
    emit(state.copyWith(
      pickedPhoto: null,
      photoUrl: property.photo,
      id: property.id,
      latitude: property.latitude,
      longitude: property.longitude,
      name: property.name,
      category: property.category,
    ));
  }

  void setNameError(String error) {
    emit(state.copyWith(nameError: error));
  }

  void clearNameError() {
    emit(state.copyWith(nameError: null));
  }

  void clearAllErrors() {
    emit(state.copyWith(
      nameError: null,
    ));
  }

  bool isSubmitEnabled() {
    if (validateName(state.name) != null ||
        state.category.isEmpty ||
        state.photoUrl == null && state.pickedPhoto == null) {
      return false;
    }

    if (_originalProperty == null) return true; // в режиме редактирования

    double round5(double val) => double.parse(val.toStringAsFixed(5));

    final sameLat =
        round5(state.latitude!) == round5(_originalProperty!.latitude);
    final sameLng =
        round5(state.longitude!) == round5(_originalProperty!.longitude);

    final hasChanges = state.name != _originalProperty!.name ||
        state.category != _originalProperty!.category ||
        state.pickedPhoto != null ||
        state.photoUrl != _originalProperty!.photo ||
        !(sameLat && sameLng);

    return hasChanges;
  }

  Future<void> pickImage(ImageSource source) async {
    final image = await _imageService.pickImage(source);
    if (image != null) {
      emit(state.copyWith(pickedPhoto: image));
    }
  }

  void removeImage() {
    emit(state.copyWith(pickedPhoto: null, photoUrl: null));
  }

  void reset() => emit(PropertyFormState(
      category: DefaultConstants.propertyTypeOptions.keys.first));
}
