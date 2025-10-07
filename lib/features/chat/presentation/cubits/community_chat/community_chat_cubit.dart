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

part 'community_chat_state.dart';

part 'community_chat_cubit.freezed.dart';

@singleton
class CommunityChatCubit extends Cubit<CommunityChatState>
    implements AutoReadSupport {
  final CommunityChatRepository _chatRepository;
  final CommunityChatSocketRepository _socketRepository;
  int? _currentOpenChatId;
  StreamSubscription? _notificationSub;

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
    _socketRepository.listenMessages((message) {
      // Если открыт конкретный чат и сообщение из него
      if (_currentOpenChatId != null &&
          message.communityId == _currentOpenChatId) {
        // Добавляем сообщение в состояние
        emit(state.copyWith(messages: [message, ...state.messages]));
      }

      // Показываем уведомление только если сообщение не из текущего открытого чата
      if (_currentOpenChatId == null ||
          message.communityId != _currentOpenChatId) {
        _incrementUnreadCount(message.communityId!);
      }
    });
  }

  void listenCommunityMessageRead() {
    _socketRepository.listenMessageRead((data) {
      // Пока просто логируем, что приходит от сервера
      print('📖 Community message read data received: $data');
    });
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
}
