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
        final conversationId = payload['senderId'] as int?;

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
    );
  }

  void listenPrivateMessages(int currentUserId) {
    AppLogger.info("Listed");
    _socketRepository.listenMessages((message) {
      final isFromCurrentChat = _currentOpenChatId != null &&
          (
              // 1️⃣ Собеседник прислал сообщение (он sender)
              message.userId == _currentOpenChatId ||
                  // 2️⃣ Я сам отправил сообщение собеседнику (receiver)
                  (message.userId == currentUserId &&
                      _currentOpenChatId != null));
      // Если открыт конкретный чат и сообщение из него
      if (isFromCurrentChat) {
        emit(state.copyWith(messages: [message, ...state.messages]));
      } else {
        _incrementUnreadCount(message.userId);
      }
    });
  }

  void listenPrivateMessageRead() {
    _socketRepository.listenMessageRead((data) {
      // Пока просто логируем, что приходит от сервера
      print('📖 Private message read data received: $data');
    });
  }

  /// Устанавливает текущий открытый чат
  void setCurrentChat(int? receiverId) {
    // Отключаем autoRead для предыдущего чата
    if (_currentOpenChatId != null) {
      disableAutoRead(_currentOpenChatId!);
    }

    _currentOpenChatId = receiverId;

    // Включаем autoRead для нового чата
    if (receiverId != null) {
      enableAutoRead(receiverId);
    }
  }

  /// Получает ID текущего открытого чата
  int? get currentOpenChatId => _currentOpenChatId;

  void joinConversation(int receiverId) {
    _socketRepository.join(receiverId);
  }

  void leaveConversation(int receiverId) {
    _socketRepository.leave(receiverId);
  }

  /// Включает автоматическое прочитывание сообщений для беседы
  void enableAutoRead(int receiverId) {
    _socketRepository.enableAutoRead(receiverId);
  }

  /// Выключает автоматическое прочитывание сообщений для беседы
  void disableAutoRead(int receiverId) {
    _socketRepository.disableAutoRead(receiverId);
  }

  /// Отмечает сообщения как прочитанные
  Future<void> markPrivateMessagesAsRead(int receiverId) async {
    emit(state.copyWith(markMessagesAsReadState: const ApiState.loading()));

    final result = await _chatRepository.markPrivateMessagesAsRead(receiverId);

    result.fold(
      (failure) => emit(state.copyWith(
        markMessagesAsReadState: ApiState.failure(failure.message),
      )),
      (_) {
        // Сбрасываем счетчик непрочитанных для этой беседы
        _unreadMessageCounts[receiverId] = 0;
        emit(state.copyWith(
          unreadMessageCounts: Map.from(_unreadMessageCounts),
          markMessagesAsReadState: const ApiState.success(null),
        ));
      },
    );
  }

  /// Увеличивает счетчик непрочитанных сообщений
  void _incrementUnreadCount(int receiverId) {
    _unreadMessageCounts[receiverId] =
        (_unreadMessageCounts[receiverId] ?? 0) + 1;
    emit(state.copyWith(
      unreadMessageCounts: Map.from(_unreadMessageCounts),
    ));
  }

  /// Получает количество непрочитанных сообщений для беседы
  int getUnreadCountForConversation(int receiverId) {
    return _unreadMessageCounts[receiverId] ?? 0;
  }

  bool get hasUnreadMessages => state.unreadMessageCounts.keys.isNotEmpty;

  // Для AutoReadSupport
  final Map<int, int> _unreadMessageCounts = {};
}
