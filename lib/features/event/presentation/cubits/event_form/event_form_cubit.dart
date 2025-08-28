import 'package:bloc/bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart' hide ImageSource;
import 'package:neighbours/core/di/injection.dart';
import 'package:neighbours/core/domain/entities/event/event_entity.dart';
import 'package:neighbours/core/services/image_service.dart';

part 'event_form_cubit.freezed.dart';

part 'event_form_state.dart';

class EventFormCubit extends Cubit<EventFormState> {
  final FullEvent? _originalEvent;

  EventFormCubit({FullEvent? event})
      : _originalEvent = event,
        super(EventFormState(
          id: event?.id ?? 0,
          title: event?.title ?? '',
          description: event?.description ?? '',
          latitude: event?.latitude ?? 0,
          longitude: event?.longitude ?? 0,
          categoryId: event?.category.id,
          imageUrl: event?.image,
          selectedDateTime: event?.eventDateTime,
          hasVoting: event?.hasVoting ?? false,
        ));

  final _imageService = getIt<ImageService>();

  Future<void> pickEventImage(ImageSource source) async {
    final image = await _imageService.pickImage(source);
    if (image != null) {
      emit(state.copyWith(image: image));
    }
  }

  void removeImage() {
    emit(state.copyWith(image: null, imageUrl: null));
  }

  void setHasVoting(bool value) {
    emit(state.copyWith(hasVoting: value));
    _validateVotingFields();
  }

  void setDescription(String value) {
    emit(state.copyWith(
      description: value,
    ));
  }

  void setVotingQuestion(String value) {
    emit(state.copyWith(votingQuestion: value));
    _validateVotingFields();
  }

  void addQuestion() {
    final updated = List<String>.from(state.votingOptions)..add('');
    emit(state.copyWith(votingOptions: updated));
    _validateVotingFields();
  }

  void updateQuestion(int index, String value) {
    final updated = List<String>.from(state.votingOptions)..[index] = value;
    emit(state.copyWith(votingOptions: updated));
    _validateVotingFields();
  }

  void removeQuestion(int index) {
    final updated = List<String>.from(state.votingOptions)..removeAt(index);
    emit(state.copyWith(votingOptions: updated));
    _validateVotingFields();
  }

  void setCategoryId(int value) {
    emit(state.copyWith(categoryId: value));
  }

  void setCoordinates({
    required double longitude,
    required double latitude,
  }) {
    emit(state.copyWith(longitude: longitude, latitude: latitude));
  }

  void onCoordsChange(Point point) {
    emit(state.copyWith(
        latitude: point.coordinates.lat.toDouble(),
        longitude: point.coordinates.lng.toDouble()));
  }

  String? validateTitle(String name) {
    if (name.trim().isEmpty) {
      return 'Название обязательно для заполнения';
    }
    if (name.trim().length < 3) {
      return 'Название должно содержать минимум 3 символа';
    }
    return null;
  }

  String? validateVotingQuestion(String? question) {
    if (state.hasVoting && (question == null || question.trim().isEmpty)) {
      return 'Вопрос для голосования обязателен';
    }
    return null;
  }

  String? validateVotingOptions(List<String> options) {
    if (state.hasVoting) {
      if (options.isEmpty) {
        return 'Должен быть как минимум один вариант для голосования';
      }

      final validOptions =
          options.where((option) => option.trim().isNotEmpty).toList();
      if (validOptions.isEmpty) {
        return 'Должен быть как минимум один вариант для голосования';
      }
    }
    return null;
  }

  void _validateVotingFields() {
    final votingQuestionError = validateVotingQuestion(state.votingQuestion);
    final votingOptionsError = validateVotingOptions(state.votingOptions);

    emit(state.copyWith(
      votingQuestionError: votingQuestionError,
      votingOptionsError: votingOptionsError,
    ));
  }

  bool get isFormValid {
    final titleValid = validateTitle(state.title) == null;
    final categoryValid = state.categoryId != null;
    final dateTimeValid = state.selectedDateTime != null;

    // При редактировании существующего события не проверяем голосование
    // так как его нельзя изменить
    if (!isNew()) {
      return titleValid && categoryValid && dateTimeValid;
    }

    // Validate voting fields only if hasVoting is true for new events
    final votingValid = !state.hasVoting ||
        (validateVotingQuestion(state.votingQuestion) == null &&
            validateVotingOptions(state.votingOptions) == null);

    return titleValid && categoryValid && dateTimeValid && votingValid;
  }

  void setName(String name) {
    final titleError = validateTitle(name);
    emit(state.copyWith(
      title: name,
      titleError: titleError,
    ));
  }

  void setDateTime(DateTime dateTime) {
    emit(state.copyWith(selectedDateTime: dateTime));
  }

  bool isNew() => _originalEvent == null;

  bool isSubmitEnabled() {
    if (!isFormValid) return false;

    // если новое событие всегда разрешаем отправку
    if (_originalEvent == null) return true;

    double round5(double val) => double.parse(val.toStringAsFixed(5));

    final hasTitleChanged = state.title != _originalEvent.title;
    final hasDescriptionChanged =
        state.description != _originalEvent.description;
    final hasCategoryChanged = state.categoryId != _originalEvent.category.id;
    final hasDateChanged =
        state.selectedDateTime != _originalEvent.eventDateTime;

    final hasCoordsChanged =
        round5(state.latitude) != round5(_originalEvent.latitude) ||
            round5(state.longitude) != round5(_originalEvent.longitude);

    final hasImageChanged =
        state.image != null || state.imageUrl != _originalEvent.image;

    final hasChanges = hasTitleChanged ||
        hasDescriptionChanged ||
        hasCategoryChanged ||
        hasDateChanged ||
        hasCoordsChanged ||
        hasImageChanged;

    return hasChanges;
  }
}
