part of 'notification_cubit.dart';

@freezed
class NotificationState with _$NotificationState {
  const factory NotificationState({
    @Default(ApiState.initial()) ApiState<void> fetchState,
    @Default([]) List<NotificationEntity> notifications,
    @Default(0) int unreadCount,
  }) = _NotificationState;
}
