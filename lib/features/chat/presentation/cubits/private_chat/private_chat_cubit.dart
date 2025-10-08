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

        AppLogger.info(payload.toString());
        final conversationId = payload['conversationId'] as int?;
        final senderId = payload['senderId'] as int?;

        if (conversationId == null) return;

        if (_currentOpenChatId != senderId) {
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
      currentConversationId: null, // Сбрасываем conversationId
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
        // Извлекаем conversationId из первого сообщения, если есть
        final conversationId =
            messages.isNotEmpty ? messages.first.conversationId : null;

        emit(state.copyWith(
          messages: messages,
          hasMoreMessages: hasMore,
          fetchMessagesState: ApiState.success(messages),
          currentConversationId: conversationId,
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
      (conversations) {
        // Сортируем беседы по updatedAt (самые новые сверху)
        final sortedConversations =
            List<PrivateChatListEntity>.from(conversations);
        sortedConversations.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));

        emit(state.copyWith(
          conversations: sortedConversations,
          fetchConversationsState: ApiState.success(sortedConversations),
        ));
      },
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

      // Обновляем lastMessage в списке conversations
      _updateLastMessageInConversations(message);
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
  Future<void> markPrivateMessagesAsRead() async {
    final conversationId = state.currentConversationId;
    if (conversationId == null) return;
    emit(state.copyWith(markMessagesAsReadState: const ApiState.loading()));

    final result =
        await _chatRepository.markPrivateMessagesAsRead(conversationId);

    result.fold(
      (failure) => emit(state.copyWith(
        markMessagesAsReadState: ApiState.failure(failure.message),
      )),
      (_) {
        // Обновляем unreadCount в conversations для этой беседы
        final updatedConversations = state.conversations.map((conversation) {
          if (conversation.id == conversationId) {
            return conversation.copyWith(unreadCount: 0);
          }
          return conversation;
        }).toList();

        emit(state.copyWith(
          conversations: updatedConversations,
          markMessagesAsReadState: const ApiState.success(null),
        ));
      },
    );
  }

  /// Увеличивает счетчик непрочитанных сообщений
  void _incrementUnreadCount(int receiverId) {
    final updatedConversations = state.conversations.map((conversation) {
      if (conversation.user.id == receiverId) {
        return conversation.copyWith(unreadCount: conversation.unreadCount + 1);
      }
      return conversation;
    }).toList();

    emit(state.copyWith(conversations: updatedConversations));
  }

  /// Получает количество непрочитанных сообщений для беседы
  int getUnreadCountForConversation() {
    try {
      if (state.currentConversationId == null) return 0;
      final conversation = state.conversations.firstWhere(
        (conv) => conv.id == state.currentConversationId,
      );
      return conversation.unreadCount;
    } catch (e) {
      // Если беседа не найдена, возвращаем 0
      return 0;
    }
  }

  bool get hasUnreadMessages =>
      state.conversations.any((conv) => conv.unreadCount > 0);

  /// Получает имя собеседника по его ID из списка conversations
  String? getInterlocutorName(int interlocutorId) {
    try {
      final conversation = state.conversations.firstWhere(
        (conv) => conv.user.id == interlocutorId,
      );
      return conversation.user.fullName;
    } catch (e) {
      // Если собеседник не найден в списке conversations, возвращаем null
      return null;
    }
  }

  /// Получает аватар собеседника по его ID из списка conversations
  String? getInterlocutorAvatar(int interlocutorId) {
    try {
      final conversation = state.conversations.firstWhere(
        (conv) => conv.user.id == interlocutorId,
      );
      return conversation.user.avatar;
    } catch (e) {
      // Если собеседник не найден в списке conversations, возвращаем null
      return null;
    }
  }

  /// Обновляет lastMessage в списке conversations при получении нового сообщения
  void _updateLastMessageInConversations(MessageEntity message) {
    final updatedConversations = state.conversations.map((conversation) {
      // Определяем, к какой беседе относится сообщение
      final isMessageForThisConversation =
          message.userId == conversation.user.id || // Сообщение от собеседника
              (message.conversationId != null &&
                  message.conversationId ==
                      conversation.id); // Или по conversationId

      if (isMessageForThisConversation) {
        // Обновляем lastMessage и updatedAt для этой беседы
        return conversation.copyWith(
          lastMessage: message,
          updatedAt: message.createdAt,
        );
      }
      return conversation;
    }).toList();

    // Сортируем беседы по updatedAt (самые новые сверху)
    updatedConversations.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));

    emit(state.copyWith(conversations: updatedConversations));
  }
}
