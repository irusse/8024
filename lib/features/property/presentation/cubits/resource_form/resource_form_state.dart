part of 'resource_form_cubit.dart';

@freezed
abstract class ResourceFormState with _$ResourceFormState {
  const factory ResourceFormState({
    @Default(0) int id,
    @Default('') String name,
    required String category,
    @Default(0) int propertyId,
    XFile? newPhotoFile,
    String? photoUrl,
    String? nameError,
  }) = _ResourceFormState;
}
