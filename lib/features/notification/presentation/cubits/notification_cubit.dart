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

  void onLogout() {
    emit(state.copyWith(notifications: [], unreadCount: 0));
  }

  void _resetStates() {
    emit(state.copyWith(fetchState: const ApiState.initial()));
  }
}
