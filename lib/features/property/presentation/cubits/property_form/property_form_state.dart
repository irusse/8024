part of 'property_form_cubit.dart';

@freezed
abstract class PropertyFormState with _$PropertyFormState {
  const factory PropertyFormState({
    @Default(0) int id,
    @Default('') String name,
    @Default(DefaultConstants.unverified) String isVerified,
    @Default(null) double? latitude,
    @Default(null) double? longitude,
    required String category,
    XFile? pickedPhoto,
    String? photoUrl,
    // Validation errors
    String? nameError,
  }) = _PropertyFormState;
}
