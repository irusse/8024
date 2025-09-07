import 'package:bloc/bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:injectable/injectable.dart';
import 'package:neighbours/features/notification/domain/entities/notification/notification_entity.dart';
import 'package:neighbours/features/notification/domain/repositories/notification_repository.dart';

import '../../../../core/state/api_state.dart';

part 'notification_cubit.freezed.dart';

part 'notification_state.dart';

@singleton
class NotificationCubit extends Cubit<NotificationState> {
  final NotificationRepository _repository;

  NotificationCubit(this._repository) : super(const NotificationState());

  Future<void> fetchNotifications({
    int page = 1,
    int limit = 10,
  }) async {
    _resetStates();
    emit(state.copyWith(fetchState: const ApiState.loading()));

    final result = await _repository.getNotifications(
      page: page,
      limit: limit,
    );

    result.fold(
        (failure) => emit(state.copyWith(
              fetchState: ApiState.failure(failure.message),
            )), (notificationList) {
      emit(state.copyWith(
        notifications: notificationList.data,
        unreadCount: notificationList.unreadCount,
        fetchState: const ApiState.success(null),
      ));
    });
  }

  Future<void> fetchUnreadCount() async {
    final result = await _repository.getUnreadCount();

    result.fold(
      (failure) {},
      (count) => emit(state.copyWith(unreadCount: count)),
    );
  }

  Future<void> deleteAllNotifications() async {
    final currentNotifications = state.notifications;
    final currentUnreadCount = state.unreadCount;

    emit(state.copyWith(
      deleteAllState: const ApiState.loading(),
      notifications: [],
      unreadCount: 0,
    ));

    final result = await _repository.deleteAllNotifications();

    result.fold(
      (failure) {
        emit(state.copyWith(
          deleteAllState: ApiState.failure(failure.message),
          notifications: currentNotifications,
          unreadCount: currentUnreadCount,
        ));
      },
      (_) {
        emit(state.copyWith(
          deleteAllState: const ApiState.success(null),
        ));
      },
    );
  }

  Future<void> markAsRead(int notificationId) async {
    // Сохраняем текущее состояние для отката в случае ошибки
    final currentNotifications = state.notifications;
    final currentUnreadCount = state.unreadCount;

    // Оптимистичное обновление: сразу отмечаем как прочитанное
    final updatedNotifications = state.notifications.map((notification) {
      if (notification.id == notificationId && !notification.isRead) {
        return notification.copyWith(isRead: true);
      }
      return notification;
    }).toList();

    // Подсчитываем новое количество непрочитанных

    final newUnreadCount = state.unreadCount - 1;

    emit(state.copyWith(
      markAsReadState: const ApiState.loading(),
      notifications: updatedNotifications,
      unreadCount: newUnreadCount,
    ));

    final result = await _repository.markAsRead(notificationId);

    result.fold(
      (failure) {
        // Откатываем изменения в случае ошибки
        emit(state.copyWith(
          markAsReadState: ApiState.failure(failure.message),
          notifications: currentNotifications,
          unreadCount: currentUnreadCount,
        ));
      },
      (_) {
        emit(state.copyWith(
          markAsReadState: const ApiState.success(null),
        ));
      },
    );
  }

  void onLogout() {
    emit(state.copyWith(notifications: [], unreadCount: 0));
  }

  void _resetStates() {
    emit(state.copyWith(
      fetchState: const ApiState.initial(),
      deleteAllState: const ApiState.initial(),
      markAsReadState: const ApiState.initial(),
    ));
  }
}
