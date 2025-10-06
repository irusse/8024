import 'dart:async';
import 'dart:convert';

import 'package:bloc/bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:injectable/injectable.dart';
import 'package:neighbours/core/constants/notification_constants.dart';
import 'package:neighbours/core/di/injection.dart';
import 'package:neighbours/core/logging/logger.dart';
import 'package:neighbours/core/services/notification_service.dart';
import 'package:neighbours/core/state/api_state.dart';
import 'package:neighbours/features/chat/domain/entities/message/message_entity.dart';
import 'package:neighbours/features/chat/domain/entities/private_chat_list/private_chat_list_entity.dart';
import 'package:neighbours/features/chat/domain/repositories/private_chat_repository.dart';
import 'package:neighbours/features/chat/domain/repositories/private_chat_socket_repository.dart';
import 'package:neighbours/core/observers/app_lifecycle_observer.dart';

part 'private_chat_state.dart';

part 'private_chat_cubit.freezed.dart';

@singleton
class PrivateChatCubit extends Cubit<PrivateChatState>
    implements AutoReadSupport {
  final PrivateChatRepository _chatRepository;
  final PrivateChatSocketRepository _socketRepository;
  int? _currentOpenChatId;
  StreamSubscription? _notificationSub;

  PrivateChatCubit(this._chatRepository, this._socketRepository)
      : super(const PrivateChatState()) {
    _notificationSub =
        getIt<NotificationService>().stream.listen((notification) {
      if (notification.type == NotificationConstants.messageReceived) {
        final payload = jsonDecode(notification.payload ?? "{}");
        final conversationId = payload['conversationId'] as int?;

        if (conversationId == null) return;

        if (_currentOpenChatId != conversationId) {
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

  Future<void> fetchPrivateMessages(int receiverId) async {
    emit(state.copyWith(
      fetchMessagesState: const ApiState.loading(),
      messages: [],
      currentPage: 1, // Сбрасываем на первую страницу
    ));

    final result = await _chatRepository.fetchPrivateMessages(
      receiverId: receiverId,
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

  Future<void> loadMoreMessages(int receiverId) async {
    if (!state.hasMoreMessages || state.isLoadingMore) return;

    emit(state.copyWith(isLoadingMore: true));
    final nextPage = state.currentPage + 1;

    final result = await _chatRepository.fetchPrivateMessages(
      receiverId: receiverId,
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

  Future<void> fetchPrivateConversations() async {
    emit(state.copyWith(
      fetchConversationsState: const ApiState.loading(),
    ));

    final result = await _chatRepository.fetchPrivateConversations();

    result.fold(
      (failure) => emit(state.copyWith(
        fetchConversationsState: ApiState.failure(failure.message),
      )),
      (conversations) => emit(state.copyWith(
        conversations: conversations,
        fetchConversationsState: ApiState.success(conversations),
      )),
    );
  }

  void sendMessage({
    required int receiverId,
    required String text,
  }) {
    AppLogger.info(receiverId.toString());
    _socketRepository.sendMessage(
      receiverId: receiverId,
      text: text,
      onConversationCreated: (newConversationId) {
        // Обновляем состояние с новым conversationId
        emit(state.copyWith(
          currentConversationId: newConversationId,
          currentReceiverId: null, // Очищаем receiverId после создания беседы
          sendMessageState: const ApiState.success(null),
        ));

        // ToDo id у event, private и community может быть ождинаковым тогда будет баг
        joinConversation(newConversationId);
        setCurrentChat(newConversationId);
      },
    );
  }

  void listenPrivateMessages() {
    _socketRepository.listenMessages((message) {
      // Если открыт конкретный чат и сообщение из него
      if (_currentOpenChatId != null &&
          message.conversationId == _currentOpenChatId) {
        // Добавляем сообщение в состояние
        emit(state.copyWith(messages: [message, ...state.messages]));
      }

      // Показываем уведомление только если сообщение не из текущего открытого чата
      if (_currentOpenChatId == null ||
          message.conversationId != _currentOpenChatId) {
        _incrementUnreadCount(message.conversationId!);
      }
    });
  }

  /// Устанавливает текущий открытый чат
  void setCurrentChat(int? conversationId) {
    // Отключаем autoRead для предыдущего чата
    if (_currentOpenChatId != null) {
      disableAutoRead(_currentOpenChatId!);
    }

    _currentOpenChatId = conversationId;

    // Включаем autoRead для нового чата
    if (conversationId != null) {
      enableAutoRead(conversationId);
    }
  }

  /// Получает ID текущего открытого чата
  int? get currentOpenChatId => _currentOpenChatId;

  void joinConversation(int conversationId) {
    _socketRepository.join(conversationId);
  }

  void leaveConversation(int conversationId) {
    _socketRepository.leave(conversationId);
  }

  /// Включает автоматическое прочитывание сообщений для беседы
  void enableAutoRead(int conversationId) {
    _socketRepository.enableAutoRead(conversationId);
  }

  /// Выключает автоматическое прочитывание сообщений для беседы
  void disableAutoRead(int conversationId) {
    _socketRepository.disableAutoRead(conversationId);
  }

  /// Отмечает сообщения как прочитанные
  Future<void> markPrivateMessagesAsRead(int conversationId) async {
    emit(state.copyWith(markMessagesAsReadState: const ApiState.loading()));

    final result =
        await _chatRepository.markPrivateMessagesAsRead(conversationId);

    result.fold(
      (failure) => emit(state.copyWith(
        markMessagesAsReadState: ApiState.failure(failure.message),
      )),
      (_) {
        // Сбрасываем счетчик непрочитанных для этой беседы
        _unreadMessageCounts[conversationId] = 0;
        emit(state.copyWith(
          unreadMessageCounts: Map.from(_unreadMessageCounts),
          markMessagesAsReadState: const ApiState.success(null),
        ));
      },
    );
  }

  /// Увеличивает счетчик непрочитанных сообщений
  void _incrementUnreadCount(int conversationId) {
    _unreadMessageCounts[conversationId] =
        (_unreadMessageCounts[conversationId] ?? 0) + 1;
    emit(state.copyWith(
      unreadMessageCounts: Map.from(_unreadMessageCounts),
      unreadPrivateTotal:
          _unreadMessageCounts.values.fold(0, (sum, count) => sum + count),
    ));
  }

  /// Получает количество непрочитанных сообщений для беседы
  int getUnreadCountForConversation(int conversationId) {
    return _unreadMessageCounts[conversationId] ?? 0;
  }

  /// Получает общее количество непрочитанных private сообщений
  int get unreadPrivateTotal => state.unreadPrivateTotal;

  // Для AutoReadSupport
  final Map<int, int> _unreadMessageCounts = {};
}
