part of 'events_cubit.dart';

@freezed
abstract class EventsState with _$EventsState {
  const factory EventsState({
    @Default({}) Map<int, EventEntity> events,
    @Default([]) List<EventCategoryEntity> categories,
    @Default(ApiState.initial()) ApiState<EventEntity> createEventState,
    @Default(ApiState.initial()) ApiState<EventEntity> createNotificationState,
    @Default(ApiState.initial()) ApiState<List<EventEntity>> fetchState,
    @Default(ApiState.initial())
    ApiState<List<EventEntity>> fetchUserEventsState,
    @Default(ApiState.initial()) ApiState<int> deleteState,
    @Default(ApiState.initial()) ApiState<EventEntity> joinEventState,
    @Default(ApiState.initial()) ApiState<EventEntity> leaveEventState,
    @Default(ApiState.initial()) ApiState<EventEntity> updateNotificationState,
    @Default(ApiState.initial()) ApiState<EventEntity> updateEventState,
    @Default(ApiState.initial()) ApiState<EventEntity> fetchEventByIdState,
    @Default(ApiState.initial())
    ApiState<List<EventCategoryEntity>> categoriesState,
  }) = _EventsState;
}
