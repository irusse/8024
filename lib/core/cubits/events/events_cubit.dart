import 'package:bloc/bloc.dart';
import 'package:collection/collection.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:image_picker/image_picker.dart';
import 'package:injectable/injectable.dart';
import 'package:neighbours/core/domain/entities/event/event_category_entity.dart';
import 'package:neighbours/core/domain/entities/event/event_entity.dart';
import 'package:neighbours/core/domain/repositories/event_repository.dart';

import '../../state/api_state.dart';

part 'events_cubit.freezed.dart';

part 'events_state.dart';

@singleton
class EventsCubit extends Cubit<EventsState> {
  final EventRepository _eventRepository;

  EventsCubit(this._eventRepository) : super(const EventsState());

  List<T> _sortedAllEvents<T>() {
    final allEvents = state.events.values.toList();

    allEvents.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return allEvents.cast<T>();
  }

  List<EventEntity> userCreatedEvents(int userId) {
    return _sortedAllEvents<EventEntity>()
        .where((event) => event.creator.id == userId)
        .toList();
  }

  List<EventEntity> userParticipatedEvents(int userId) {
    return _sortedAllEvents<EventEntity>()
        .where((event) => event.participants.any((p) => p.id == userId))
        .toList();
  }

  List<EventEntity> allUserFullEvents(int userId) {
    return state.events.values
        .where((event) =>
            event.participants.any((p) => p.id == userId) ||
            event.creator.id == userId && event.isFullEvent)
        .toList();
  }

  List<EventEntity> allUserNotifications(int userId) {
    return state.events.values
        .where((event) =>
            event.participants.any((p) => p.id == userId) ||
            event.creator.id == userId && event.isNotification)
        .toList();
  }

  List<EventEntity> allFullEvents() {
    return state.events.values.where((event) => event.isFullEvent).toList();
  }

  List<EventEntity> allNotifications() {
    return state.events.values.where((event) => event.isNotification).toList();
  }

  Future<void> createNotification({
    required String title,
    required double latitude,
    required double longitude,
    required int categoryId,
    required int communityId,
    required String description,
  }) async {
    _resetStates();
    emit(state.copyWith(createNotificationState: const ApiState.loading()));

    final result = await _eventRepository.createNotification(
      title: title,
      latitude: latitude,
      longitude: longitude,
      categoryId: categoryId,
      communityId: communityId,
      description: description,
    );

    result.fold(
      (failure) => emit(state.copyWith(
        createNotificationState: ApiState.failure(failure.message),
      )),
      (entity) => _handleEntityCreated(entity),
    );
  }

  Future<void> createEvent({
    required String title,
    required String description,
    required int categoryId,
    required double latitude,
    required double longitude,
    required int communityId,
    required bool hasVoting,
    String? votingQuestion,
    List<String>? votingOptions,
    XFile? pickedImage,
    DateTime? eventDateTime,
  }) async {
    _resetStates();
    emit(state.copyWith(createEventState: const ApiState.loading()));

    final result = await _eventRepository.createEvent(
      title: title,
      description: description,
      categoryId: categoryId,
      latitude: latitude,
      longitude: longitude,
      communityId: communityId,
      hasVoting: hasVoting,
      votingQuestion: votingQuestion,
      votingOptions: votingOptions,
      pickedImage: pickedImage,
      eventDateTime: eventDateTime,
    );

    result.fold(
      (failure) => emit(state.copyWith(
        createEventState: ApiState.failure(failure.message),
      )),
      (entity) => _handleEntityCreated(entity),
    );
  }

  EventCategoryEntity? getEventCategoryById(int? categoryId) =>
      state.categories.firstWhereOrNull((c) => c.id == categoryId);

  Future<void> fetchCommunityEvents({
    required String communityId,
    String? type,
    int? categoryId,
    int? page,
    int? limit,
  }) async {
    _resetStates();
    emit(state.copyWith(fetchState: const ApiState.loading()));

    final result = await _eventRepository.fetchCommunityEvents(
      communityId: communityId,
      type: type,
      categoryId: categoryId,
      page: page,
      limit: limit,
    );

    result.fold(
      (failure) => emit(state.copyWith(
        fetchState: ApiState.failure(failure.message),
      )),
      (entities) => _handleEntitiesFetched(entities),
    );
  }

  Future<void> fetchEventById({required String eventId}) async {
    _resetStates();
    emit(state.copyWith(fetchEventByIdState: const ApiState.loading()));

    final result = await _eventRepository.fetchEventById(eventId: eventId);

    result.fold(
        (failure) => emit(state.copyWith(
              fetchEventByIdState: ApiState.failure(failure.message),
            )), (entity) {
      final updated = {...state.events};
      updated[entity.id] = entity;
      emit(state.copyWith(
          events: updated, fetchEventByIdState: ApiState.success(entity)));
    });
  }

  Future<void> deleteEvent({required String eventId}) async {
    _resetStates();
    final int? id = int.tryParse(eventId);
    if (id == null) return;
    final previousState = state;
    _removeEventOptimistically(id);

    emit(state.copyWith(deleteState: const ApiState.loading()));

    final result = await _eventRepository.deleteEvent(eventId: eventId);

    result.fold(
      (failure) => _handleDeleteFailure(failure.message, previousState),
      (_) => emit(state.copyWith(
        deleteState: ApiState.success(int.parse(eventId)),
      )),
    );
  }

  Future<void> fetchEventCategories() async {
    _resetStates();
    emit(state.copyWith(categoriesState: const ApiState.loading()));

    final result = await _eventRepository.fetchEventCategories();

    result.fold(
      (failure) => emit(state.copyWith(
        categoriesState: ApiState.failure(failure.message),
      )),
      (categories) => emit(state.copyWith(
        categories: categories,
        categoriesState: ApiState.success(categories),
      )),
    );
  }

  Future<void> joinEvent({required String eventId}) async {
    _resetStates();
    final int? id = int.tryParse(eventId);
    if (id == null) return;

    emit(state.copyWith(joinEventState: const ApiState.loading()));

    final result = await _eventRepository.joinEvent(eventId: eventId);

    result.fold(
      (failure) => emit(state.copyWith(
        joinEventState: ApiState.failure(failure.message),
      )),
      (entity) => _handleEventUpdated(entity, isJoin: true),
    );
  }

  Future<void> leaveEvent({required String eventId}) async {
    _resetStates();
    final int? id = int.tryParse(eventId);
    if (id == null) return;

    emit(state.copyWith(leaveEventState: const ApiState.loading()));

    final result = await _eventRepository.leaveEvent(eventId: eventId);

    result.fold(
      (failure) => emit(state.copyWith(
        leaveEventState: ApiState.failure(failure.message),
      )),
      (entity) => _handleEventUpdated(entity, isJoin: false),
    );
  }

  Future<void> updateNotification({
    required String id,
    required String title,
    required String description,
    required double latitude,
    required double longitude,
    required int categoryId,
  }) async {
    _resetStates();
    emit(state.copyWith(updateNotificationState: const ApiState.loading()));

    final result = await _eventRepository.updateNotification(
      id: id,
      title: title,
      description: description,
      latitude: latitude,
      longitude: longitude,
      categoryId: categoryId,
    );

    result.fold(
      (failure) => emit(state.copyWith(
        updateNotificationState: ApiState.failure(failure.message),
      )),
      (entity) => _handleEventUpdated(entity),
    );
  }

  Future<void> updateEvent({
    required String id,
    required String title,
    required double latitude,
    required double longitude,
    required int categoryId,
    required DateTime eventDateTime,
    required String description,
    String? image,
    XFile? pickedImage,
    String? votingQuestion,
    List<String>? votingOptions,
    required bool hasVoting,
  }) async {
    _resetStates();
    emit(state.copyWith(updateEventState: const ApiState.loading()));

    final result = await _eventRepository.updateEvent(
      id: id,
      title: title,
      description: description,
      latitude: latitude,
      longitude: longitude,
      categoryId: categoryId,
      eventDateTime: eventDateTime,
      image: image,
      pickedImage: pickedImage,
      votingQuestion: votingQuestion,
      votingOptions: votingOptions,
      hasVoting: hasVoting,
    );

    result.fold(
      (failure) => emit(state.copyWith(
        updateEventState: ApiState.failure(failure.message),
      )),
      (entity) => _handleEventUpdated(entity),
    );
  }

  void _resetStates() {
    emit(state.copyWith(
        createNotificationState: const ApiState.initial(),
        createEventState: const ApiState.initial(),
        updateNotificationState: const ApiState.initial(),
        updateEventState: const ApiState.initial(),
        categoriesState: const ApiState.initial(),
        fetchState: const ApiState.initial(),
        fetchEventByIdState: const ApiState.initial(),
        deleteState: const ApiState.initial(),
        joinEventState: const ApiState.initial(),
        leaveEventState: const ApiState.initial()));
  }

  void onLogout() {
    emit(state.copyWith(events: {}));
  }

  void _removeEventOptimistically(int id) {
    final updatedEvents = Map<int, EventEntity>.from(state.events);
    if (updatedEvents.containsKey(id)) {
      updatedEvents.remove(id);
      emit(state.copyWith(events: updatedEvents));
    }
  }

  void _handleDeleteFailure(String message, EventsState previousState) {
    emit(previousState.copyWith(
      deleteState: ApiState.failure(message),
    ));
  }

  void _handleEntitiesFetched(List<EventEntity> entities) {
    final events = Map<int, EventEntity>.from(state.events);

    for (final entity in entities) {
      events[entity.id] = entity;
    }

    emit(state.copyWith(
      events: events,
      fetchState: ApiState.success(entities),
    ));
  }

  void _handleEntityCreated(EventEntity entity) {
    final updatedEvents = {
      entity.id: entity,
      ...state.events,
    };
    emit(state.copyWith(
      events: updatedEvents,
      createEventState: ApiState.success(entity),
    ));
  }

  void _handleEventUpdated(EventEntity entity, {bool? isJoin}) {
    final updatedEvents = {...state.events};
    updatedEvents[entity.id] = entity;
    emit(state.copyWith(
      events: updatedEvents,
      updateEventState: ApiState.success(entity),
      joinEventState:
          isJoin == true ? ApiState.success(entity) : state.joinEventState,
      leaveEventState:
          isJoin == false ? ApiState.success(entity) : state.leaveEventState,
    ));
  }
}
