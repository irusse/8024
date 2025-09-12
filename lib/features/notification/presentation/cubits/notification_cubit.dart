import 'package:bloc/bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:injectable/injectable.dart';
import 'package:neighbours/core/services/notification_service.dart';
import 'package:neighbours/features/notification/domain/entities/notification/notification_entity.dart';
import 'package:neighbours/features/notification/domain/repositories/notification_repository.dart';

import '../../../../core/state/api_state.dart';

part 'notification_cubit.freezed.dart';

part 'notification_state.dart';

@singleton
class NotificationCubit extends Cubit<NotificationState> {
  final NotificationRepository _repository;

  NotificationCubit(this._repository, NotificationService service)
      : super(const NotificationState()) {
    service.stream.listen((notification) {
      emit(state.copyWith(unreadCount: state.unreadCount + 1));
    });
  }

  bool get hasUnreadNotifications => state.unreadCount > 0;

  Future<void> fetchNotifications({
    int page = 1,
    int limit = 10,
    bool refresh = false,
  }) async {
    if (refresh) {
      _resetStates();
      emit(state.copyWith(
        fetchState: const ApiState.loading(),
        notifications: [],
        currentPage: 1,
        hasMore: true,
      ));
    } else {
      _resetStates();
      emit(state.copyWith(fetchState: const ApiState.loading()));
    }

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
        currentPage: page,
        hasMore: notificationList.data.length >= limit,
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
    emit(state.copyWith(
      notifications: [],
      unreadCount: 0,
      currentPage: 1,
      hasMore: true,
      isLoadingMore: false,
    ));
  }

  Future<void> loadMoreNotifications({
    int limit = 10,
  }) async {
    if (!state.hasMore || state.isLoadingMore) return;

    emit(state.copyWith(
      loadMoreState: const ApiState.loading(),
      isLoadingMore: true,
    ));

    final nextPage = state.currentPage + 1;
    final result = await _repository.getNotifications(
      page: nextPage,
      limit: limit,
    );

    result.fold(
      (failure) => emit(state.copyWith(
        loadMoreState: ApiState.failure(failure.message),
        isLoadingMore: false,
      )),
      (notificationList) {
        final allNotifications = [
          ...state.notifications,
          ...notificationList.data
        ];
        emit(state.copyWith(
          notifications: allNotifications,
          unreadCount: notificationList.unreadCount,
          currentPage: nextPage,
          hasMore: notificationList.data.length >= limit,
          loadMoreState: const ApiState.success(null),
          isLoadingMore: false,
        ));
      },
    );
  }

  void _resetStates() {
    emit(state.copyWith(
      fetchState: const ApiState.initial(),
      deleteAllState: const ApiState.initial(),
      markAsReadState: const ApiState.initial(),
      loadMoreState: const ApiState.initial(),
    ));
  }
}
