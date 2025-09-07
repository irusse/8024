import 'package:bloc/bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';
import 'package:neighbours/core/domain/entities/event/event_entity.dart';

part 'notification_form_cubit.freezed.dart';

part 'notification_form_state.dart';

class NotificationFormCubit extends Cubit<NotificationFormState> {
  final EventEntity? _originalEvent;

  NotificationFormCubit({EventEntity? event})
      : _originalEvent = event,
        super(NotificationFormState(
          id: event?.id ?? 0,
          title: event?.title ?? '',
          latitude: event?.latitude ?? 0,
          longitude: event?.longitude ?? 0,
          categoryId: event?.category.id,
          description: event?.description ?? '',
          image: event?.image,
        ));

  void changeDescription(String description) {
    emit(state.copyWith(description: description, descriptionDirty: true));
  }

  bool isNew() => _originalEvent == null;

  void changeCategoryId(int id) {
    emit(state.copyWith(categoryId: id));
  }

  void onCoordsChange(Point point) {
    emit(state.copyWith(
        latitude: point.coordinates.lat.toDouble(),
        longitude: point.coordinates.lng.toDouble()));
  }

  bool isSubmitEnabled() {
    if (state.description.trim().isEmpty || state.categoryId == null) {
      return false;
    }

    if (_originalEvent == null) return true;

    double round5(double val) => double.parse(val.toStringAsFixed(5));

    final sameLat = round5(state.latitude) == round5(_originalEvent.latitude);
    final sameLng = round5(state.longitude) == round5(_originalEvent.longitude);
    final hasChanges = state.description != _originalEvent.description ||
        state.categoryId != _originalEvent.category.id ||
        !(sameLat && sameLng);

    return hasChanges;
  }
}
