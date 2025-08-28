part of 'event_form_cubit.dart';

@freezed
class EventFormState with _$EventFormState {
  const EventFormState._();

  const factory EventFormState({
    @Default(0) int id,
    required String title,
    @Default(false) bool hasVoting,
    String? titleError,
    String? votingQuestion,
    String? votingQuestionError,
    @Default([]) List<String> votingOptions,
    String? votingOptionsError,
    int? categoryId,
    @Default(0.0) double latitude,
    @Default(0.0) double longitude,
    XFile? image,
    String? imageUrl,
    @Default('') String description,
    DateTime? selectedDateTime,
  }) = _EventFormState;

  List<String> get cleanedOptions =>
      votingOptions.where((o) => o.trim().isNotEmpty).toList();
}
