import 'dart:async';
import 'dart:convert';
import 'package:bloc/bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:injectable/injectable.dart';
import 'package:neighbours/core/constants/notification_constants.dart';
import 'package:neighbours/core/di/injection.dart';
import 'package:neighbours/core/services/notification_service.dart';
import 'package:neighbours/core/state/api_state.dart';
import 'package:neighbours/features/chat/domain/entities/message/message_entity.dart';
import 'package:neighbours/features/chat/domain/repositories/event_chat_repository.dart';
import 'package:neighbours/features/chat/domain/repositories/event_chat_socket_repository.dart';
import 'package:neighbours/core/observers/app_lifecycle_observer.dart';

part 'event_chat_state.dart';

part 'event_chat_cubit.freezed.dart';

@singleton
class EventChatCubit extends Cubit<EventChatState> implements AutoReadSupport {
  final EventChatRepository _chatRepository;
  final EventChatSocketRepository _socketRepository;
  int? _currentOpenChatId;
  StreamSubscription? _notificationSub;

  EventChatCubit(this._chatRepository, this._socketRepository)
      : super(EventChatState()) {
    _notificationSub =
        getIt<NotificationService>().stream.listen((notification) {
      if (notification.type == NotificationConstants.messageReceived) {
        final payload = jsonDecode(notification.payload ?? "{}");
        final eventId = payload['eventId'] as int?;

        if (eventId == null) return;

        if (_currentOpenChatId != eventId) {
          getIt<NotificationService>().showBasicNotification(notification);
        }
      }
    });

    // Регистрируем кубит в едином observer
    getIt<AppLifecycleObserver>().addCubit(this);
  }

  @override
  Future<void> close() {
    _notificationSub?.cancel();
    getIt<AppLifecycleObserver>().removeCubit(this);
    return super.close();
  }

  Future<void> fetchEventMessages(int eventId) async {
    emit(state
        .copyWith(fetchMessagesState: const ApiState.loading(), messages: []));

    final result = await _chatRepository.fetchEventMessages(
      eventId: eventId,
      page: state.currentPage,
      limit: state.limit,
    );

    result.fold(
      (failure) => emit(state.copyWith(
        fetchMessagesState: ApiState.failure(failure.message),
      )),
      (messages) {
        final hasMore = messages.length >= state.limit;
        emit(state.copyWith(
          messages: messages,
          hasMoreMessages: hasMore,
          fetchMessagesState: ApiState.success(messages),
        ));
      },
    );
  }

  Future<void> loadMoreMessages(int eventId) async {
    if (!state.hasMoreMessages || state.isLoadingMore) return;

    emit(state.copyWith(isLoadingMore: true));
    final nextPage = state.currentPage + 1;

    final result = await _chatRepository.fetchEventMessages(
      eventId: eventId,
      page: nextPage,
      limit: state.limit,
    );

    result.fold(
      (failure) => emit(state.copyWith(
        isLoadingMore: false,
      )),
      (newMessages) {
        final hasMore = newMessages.length >= state.limit;
        emit(state.copyWith(
          currentPage: nextPage,
          messages: [...state.messages, ...newMessages],
          hasMoreMessages: hasMore,
          isLoadingMore: false,
        ));
      },
    );
  }

  void addSocketMessage(int eventId, String text) {
    _socketRepository.sendMessage(eventId, text);
  }

  void listenEventMessages() {
    _socketRepository.listenMessages((message) {
      // Если открыт конкретный чат и сообщение из него
      if (_currentOpenChatId != null && message.eventId == _currentOpenChatId) {
        // Добавляем сообщение в состояние
        emit(state.copyWith(messages: [message, ...state.messages]));
      }

      // Показываем уведомление только если сообщение не из текущего открытого чата
      if (_currentOpenChatId == null || message.eventId != _currentOpenChatId) {
        _incrementUnreadCount(message.eventId!);
      }
    });
  }

  /// Устанавливает текущий открытый чат
  void setCurrentChat(int? eventId) {
    // Отключаем autoRead для предыдущего чата
    if (_currentOpenChatId != null) {
      disableAutoRead(_currentOpenChatId!);
    }
    
    _currentOpenChatId = eventId;
    
    // Включаем autoRead для нового чата
    if (eventId != null) {
      enableAutoRead(eventId);
    }
  }

  /// Получает ID текущего открытого чата
  int? get currentOpenChatId => _currentOpenChatId;

  void joinEvent(int eventId) {
    _socketRepository.join(eventId);
  }

  void leaveEvent(int eventId) {
    _socketRepository.leave(eventId);
  }

  /// Включает автоматическое прочитывание сообщений для события
  void enableAutoRead(int eventId) {
    _socketRepository.enableAutoRead(eventId);
  }

  /// Выключает автоматическое прочитывание сообщений для события
  void disableAutoRead(int eventId) {
    _socketRepository.disableAutoRead(eventId);
  }

  /// Получает количество непрочитанных сообщений для всех событий
  Future<void> fetchUnreadMessageCounts(int userId) async {
    emit(state.copyWith(fetchUnreadCountsState: const ApiState.loading()));

    final result = await _chatRepository.fetchUnreadMessages(userId);

    result.fold(
      (failure) => emit(state.copyWith(
        fetchUnreadCountsState: ApiState.failure(failure.message),
      )),
      (entity) {
        emit(state.copyWith(
          unreadMessageCounts: entity.count,
          fetchUnreadCountsState: const ApiState.success(null),
        ));
      },
    );
  }

  /// Отмечает сообщения события как прочитанные
  Future<void> markEventMessagesAsRead(int eventId) async {
    final result = await _chatRepository.markEventMessagesAsRead(eventId);

    result.fold(
      (failure) => emit(state.copyWith(
          markMessagesAsReadState: ApiState.failure(failure.message))),
      (_) {
        emit(state.copyWith(
            markMessagesAsReadState: const ApiState.success(null)));
        removeEventCount(eventId);
      },
    );
  }

  void removeEventCount(eventId) {
    final updatedCounts = Map<int, int>.from(state.unreadMessageCounts);
    updatedCounts.remove(eventId);
    emit(state.copyWith(unreadMessageCounts: updatedCounts));
  }

  /// Увеличивает счетчик непрочитанных сообщений для события
  void _incrementUnreadCount(int eventId) {
    final updatedCounts = Map<int, int>.from(state.unreadMessageCounts);
    updatedCounts[eventId] = (updatedCounts[eventId] ?? 0) + 1;
    emit(state.copyWith(unreadMessageCounts: updatedCounts));
  }

  /// Проверяет, есть ли непрочитанные сообщения
  bool get hasUnreadMessages => state.unreadMessageCounts.keys.isNotEmpty;

  /// Получает количество непрочитанных сообщений для конкретного события
  int getUnreadCountForEvent(int eventId) {
    return state.unreadMessageCounts[eventId] ?? 0;
  }
}
