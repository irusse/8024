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
import 'package:neighbours/features/chat/domain/repositories/community_chat_repository.dart';
import 'package:neighbours/features/chat/domain/repositories/community_chat_socket_repository.dart';

part 'community_chat_state.dart';

part 'community_chat_cubit.freezed.dart';

@singleton
class CommunityChatCubit extends Cubit<CommunityChatState> {
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
  }

  @override
  Future<void> close() {
    _notificationSub?.cancel();
    return super.close();
  }

  Future<void> fetchCommunityMessages(int communityId) async {
    emit(state
        .copyWith(fetchMessagesState: const ApiState.loading(), messages: []));

    final result = await _chatRepository.fetchCommunityMessages(
      communityId: communityId,
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

  /// Устанавливает текущий открытый чат
  void setCurrentChat(int? communityId) {
    _currentOpenChatId = communityId;
  }

  /// Получает ID текущего открытого чата
  int? get currentOpenChatId => _currentOpenChatId;

  void join(int communityId) {
    _socketRepository.join(communityId);
  }

  void leave(int communityId) {
    _socketRepository.leave(communityId);
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
