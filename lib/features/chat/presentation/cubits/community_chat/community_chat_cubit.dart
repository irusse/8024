import 'dart:async';
import 'dart:convert';

import 'package:bloc/bloc.dart';
import 'package:flutter/widgets.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:injectable/injectable.dart';
import 'package:neighbours/core/constants/notification_constants.dart';
import 'package:neighbours/core/di/injection.dart';
import 'package:neighbours/core/services/notification_service.dart';
import 'package:neighbours/core/state/api_state.dart';
import 'package:neighbours/features/chat/domain/entities/message/message_entity.dart';
import 'package:neighbours/features/chat/domain/repositories/community_chat_repository.dart';
import 'package:neighbours/features/chat/domain/repositories/community_chat_socket_repository.dart';
import 'package:neighbours/core/observers/app_lifecycle_observer.dart';
import 'package:neighbours/features/chat/data/models/message_read/message_read_model.dart';
import 'package:neighbours/features/chat/domain/entities/message_read/message_read_entity.dart';
import 'package:neighbours/features/chat/domain/entities/seen_user/seen_user_entity.dart';
import 'package:neighbours/core/logging/logger.dart';

part 'community_chat_state.dart';

part 'community_chat_cubit.freezed.dart';

@singleton
class CommunityChatCubit extends Cubit<CommunityChatState>
    implements AutoReadSupport {
  final CommunityChatRepository _chatRepository;
  final CommunityChatSocketRepository _socketRepository;
  int? _currentOpenChatId;
  StreamSubscription? _notificationSub;

  // Кэш для быстрого поиска сообщений по ID
  final Map<int, int> _messageIndexCache = {};
  
  // Флаги для предотвращения дублирования слушателей
  bool _messagesListenerInitialized = false;
  bool _messageReadListenerInitialized = false;

  CommunityChatCubit(this._chatRepository, this._socketRepository)
      : super(CommunityChatState()) {
    _notificationSub =
        getIt<NotificationService>().stream.listen((notification) {
      if (notification.type == NotificationConstants.messageReceived) {
        final payload = jsonDecode(notification.payload ?? "{}");
        final communityId = payload['communityId'] as int?;

        if (communityId == null) return;
        if (_currentOpenChatId != communityId) {
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

  Future<void> fetchCommunityMessages(int communityId) async {
    emit(state.copyWith(
      fetchMessagesState: const ApiState.loading(),
      messages: [],
      currentPage: 1, // Сбрасываем на первую страницу
    ));

    final result = await _chatRepository.fetchCommunityMessages(
      communityId: communityId,
      page: 1, // Всегда начинаем с первой страницы
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

  Future<void> loadMoreMessages(int communityId) async {
    if (!state.hasMoreMessages || state.isLoadingMore) return;

    emit(state.copyWith(isLoadingMore: true));
    final nextPage = state.currentPage + 1;

    final result = await _chatRepository.fetchCommunityMessages(
      communityId: communityId,
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

  void addSocketMessage(int communityId, String text) {
    _socketRepository.sendMessage(communityId, text);
  }

  void listenCommunityMessages() {
    if (_messagesListenerInitialized) {
      AppLogger.warning("Community messages listener already initialized, skipping");
      return;
    }
    
    AppLogger.warning("Initializing community messages listener");
    _socketRepository.listenMessages((message) {
      // Проверяем, что сообщение не дублируется
      if (state.messages.any((existingMessage) => existingMessage.id == message.id)) {
        AppLogger.warning("Duplicate community message detected, skipping: ${message.id}");
        return;
      }

      // Если открыт конкретный чат и сообщение из него
      if (_currentOpenChatId != null &&
          message.communityId == _currentOpenChatId) {
        // Добавляем сообщение в состояние
        final newMessages = [message, ...state.messages];

        // Обновляем кэш индексов сообщений
        _updateMessageIndexCache(newMessages);

        emit(state.copyWith(messages: newMessages));
      }

      // Показываем уведомление только если сообщение не из текущего открытого чата
      if (_currentOpenChatId == null ||
          message.communityId != _currentOpenChatId) {
        _incrementUnreadCount(message.communityId!);
      }
    });
    
    _messagesListenerInitialized = true;
  }

  void listenCommunityMessageRead() {
    if (_messageReadListenerInitialized) return;
    
    _socketRepository.listenMessageRead((data) {
      AppLogger.info('📖 Community message read data received: $data');

      try {
        // Парсим данные прочтения сообщения
        final messageRead = MessageReadModel.fromJson(data).toEntity();

        // Обновляем seenUsers в соответствующем сообщении
        _updateMessageSeenStatus(messageRead);
      } catch (e, st) {
        print(e);
        print(st);
        AppLogger.error('Error parsing community message read data: $e');
      }
    });
    
    _messageReadListenerInitialized = true;
  }

  /// Устанавливает текущий открытый чат
  void setCurrentChat(int? communityId) {
    // Отключаем autoRead для предыдущего чата
    if (_currentOpenChatId != null) {
      disableAutoRead(_currentOpenChatId!);
    }

    _currentOpenChatId = communityId;

    // Включаем autoRead для нового чата
    if (communityId != null) {
      enableAutoRead(communityId);
    }
  }

  /// Получает ID текущего открытого чата
  int? get currentOpenChatId => _currentOpenChatId;

  void join(int communityId) {
    _socketRepository.join(communityId);
  }

  void leave(int communityId) {
    _socketRepository.leave(communityId);
  }

  /// Включает автоматическое прочитывание сообщений для сообщества
  void enableAutoRead(int communityId) {
    _socketRepository.enableAutoRead(communityId);
  }

  /// Выключает автоматическое прочитывание сообщений для сообщества
  void disableAutoRead(int communityId) {
    _socketRepository.disableAutoRead(communityId);
  }

  /// Получает количество непрочитанных сообщений для всех сообществ
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

  Future<void> markCommunityMessagesAsRead(int communityId) async {
    emit(state.copyWith(markMessagesAsReadState: const ApiState.loading()));

    final result =
        await _chatRepository.markCommunityMessagesAsRead(communityId);

    result.fold(
      (failure) => emit(state.copyWith(
          markMessagesAsReadState: ApiState.failure(failure.message))),
      (_) {
        emit(state.copyWith(
            markMessagesAsReadState: const ApiState.success(null)));
        removeCommunityCount(communityId);
      },
    );
  }

  void removeCommunityCount(communityId) {
    final updatedCounts = Map<int, int>.from(state.unreadMessageCounts);
    updatedCounts.remove(communityId);
    emit(state.copyWith(unreadMessageCounts: updatedCounts));
  }

  void _incrementUnreadCount(int communityId) {
    final updatedCounts = Map<int, int>.from(state.unreadMessageCounts);
    updatedCounts[communityId] = (updatedCounts[communityId] ?? 0) + 1;
    emit(state.copyWith(unreadMessageCounts: updatedCounts));
  }

  bool get hasUnreadMessages => state.unreadMessageCounts.keys.isNotEmpty;

  int getUnreadCountForCommunity(int communityId) {
    return state.unreadMessageCounts[communityId] ?? 0;
  }

  /// Обновляет кэш индексов сообщений
  void _updateMessageIndexCache(List<MessageEntity> messages) {
    _messageIndexCache.clear();
    for (int i = 0; i < messages.length; i++) {
      _messageIndexCache[messages[i].id] = i;
    }
  }

  /// Обновляет статус прочтения сообщения при получении события прочтения
  void _updateMessageSeenStatus(MessageReadEntity messageRead) {
    // Оптимизация: используем кэш для O(1) поиска
    final messageIndex = _messageIndexCache[messageRead.message.id];

    // Если сообщение не найдено в кэше, выходим
    if (messageIndex == null || messageIndex >= state.messages.length) return;

    final targetMessage = state.messages[messageIndex];

    // Создаем новый SeenUser
    final newSeenUser = SeenUserEntity(
      seenAt: messageRead.seenAt,
      user: messageRead.user,
    );

    // Оптимизация: используем Map для быстрого поиска пользователей
    final currentSeenUsers = targetMessage.seenUsers ?? [];
    final seenUsersMap = <int, SeenUserEntity>{
      for (final seenUser in currentSeenUsers) seenUser.user.id: seenUser
    };

    // Обновляем или добавляем пользователя
    seenUsersMap[messageRead.user.id] = newSeenUser;

    // Создаем обновленный список seenUsers
    final updatedSeenUsers = seenUsersMap.values.toList();

    // Создаем обновленное сообщение
    final updatedMessage = targetMessage.copyWith(
      seenUsers: updatedSeenUsers,
      isRead: updatedSeenUsers.isNotEmpty,
    );

    // Оптимизация: обновляем только нужное сообщение
    final updatedMessages = List<MessageEntity>.from(state.messages);
    updatedMessages[messageIndex] = updatedMessage;

    emit(state.copyWith(messages: updatedMessages));
  }

  /// Сбрасывает слушатели (для предотвращения дублирования)
  void resetListeners() {
    AppLogger.warning("Resetting community chat listeners");
    _messagesListenerInitialized = false;
    _messageReadListenerInitialized = false;
  }

  /// Сбрасывает состояние кубита при логауте
  void onLogout() {
    AppLogger.warning("Community chat cubit logout - resetting all state");
    _messagesListenerInitialized = false;
    _messageReadListenerInitialized = false;
    _currentOpenChatId = null;
    _messageIndexCache.clear();
    emit(CommunityChatState());
  }
}
