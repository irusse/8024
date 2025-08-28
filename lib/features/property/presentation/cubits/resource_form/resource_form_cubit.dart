import 'package:bloc/bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:image_picker/image_picker.dart';
import 'package:neighbours/core/di/injection.dart';
import 'package:neighbours/core/services/image_service.dart';
import 'package:neighbours/features/property/domain/entities/resource/resource_entity.dart';

import '../../../../../core/constants/default_constants.dart';

part 'resource_form_cubit.freezed.dart';

part 'resource_form_state.dart';

class ResourceFormCubit extends Cubit<ResourceFormState> {
  ResourceEntity? _originalResource;

  ResourceFormCubit({ResourceEntity? resource})
      : _originalResource = resource,
        super(ResourceFormState(
            name: resource?.name ?? '',
            id: resource?.id ?? 0,
            photoUrl: resource?.photo,
            category: resource?.category ??
                DefaultConstants.resourceTypeOptions.keys.toList()[0],
            propertyId: resource?.propertyId ?? 0));
  final _imageService = getIt<ImageService>();

  List<String> get typeApiValues =>
      DefaultConstants.resourceTypeOptions.keys.toList();

  List<String> get typeLabels =>
      DefaultConstants.resourceTypeOptions.values.toList();

  String getLabel(String apiValue) =>
      DefaultConstants.resourceTypeOptions[apiValue]!;

  String getApiTypeByLabel(String label) =>
      DefaultConstants.resourceTypeOptions.entries
          .firstWhere((e) => e.value == label)
          .key;

  String? validateName(String name) {
    if (name.trim().isEmpty) {
      return 'Название ресурса обязательно для заполнения';
    }
    if (name.trim().length < 3) {
      return 'Название ресурса должно содержать минимум 3 символа';
    }
    return null;
  }

  void setCategory(String apiType) {
    emit(state.copyWith(category: apiType));
  }

  void setPropertyId(int propertyId) {
    emit(state.copyWith(propertyId: propertyId));
  }

  void updateName(String name) {
    emit(state.copyWith(
      name: name,
      nameError: validateName(name),
    ));
  }

  void resetOriginalResource(ResourceEntity resource) {
    _originalResource = resource;
    emit(state.copyWith(
        newPhotoFile: null, photoUrl: resource.photo, id: resource.id));
  }

  bool isNewResource() => _originalResource == null;

  bool isSubmitEnabled() {
    final nameError = validateName(state.name);
    if (nameError != null) {
      return false;
    }
    if (_originalResource == null) {
      return true;
    }

    final hasChanges = state.name != _originalResource!.name ||
        state.category != _originalResource!.category ||
        state.newPhotoFile != null ||
        state.photoUrl != _originalResource!.photo;

    return hasChanges;
  }

  Future<void> pickImageFromGallery() async {
    final XFile? image = await _imageService.pickImage(
      ImageSource.gallery,
    );

    if (image != null) {
      emit(state.copyWith(newPhotoFile: image));
    }
  }

  void removeImage() {
    emit(state.copyWith(newPhotoFile: null, photoUrl: null));
  }
}
