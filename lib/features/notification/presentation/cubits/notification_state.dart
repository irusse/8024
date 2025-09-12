part of 'notification_cubit.dart';

@freezed
class NotificationState with _$NotificationState {
  const factory NotificationState({
    @Default(ApiState.initial()) ApiState<void> fetchState,
    @Default(ApiState.initial()) ApiState<void> deleteAllState,
    @Default(ApiState.initial()) ApiState<void> markAsReadState,
    @Default(ApiState.initial()) ApiState<void> loadMoreState,
    @Default([]) List<NotificationEntity> notifications,
    @Default(0) int unreadCount,
    @Default(1) int currentPage,
    @Default(true) bool hasMore,
    @Default(false) bool isLoadingMore,
  }) = _NotificationState;
}
