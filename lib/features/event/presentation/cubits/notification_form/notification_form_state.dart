part of 'notification_form_cubit.dart';

@freezed
abstract class NotificationFormState with _$NotificationFormState {
  const factory NotificationFormState({
    @Default(0) int id,
    @Default('') String title,
    @Default(0) double latitude,
    @Default(0) double longitude,
    @Default('') String description,
    String? image,
    int? categoryId,
    @Default(false) bool descriptionDirty,
  }) = _NotificationFormState;
}
