part of 'private_message_cubit.dart';

@freezed
abstract class PrivateMessageState with _$PrivateMessageState {
  const factory PrivateMessageState({
    @Default([]) List<MessageEntity> messages,
    @Default(ApiState.initial())
    ApiState<List<MessageEntity>> fetchMessagesState,
    @Default(ApiState.initial()) ApiState<void> sendMessageState,
    @Default(ApiState.initial()) ApiState<void> markMessagesAsReadState,
    @Default(1) int currentPage,
    @Default(40) int limit,
    @Default(false) bool hasMoreMessages,
    @Default({}) Map<int, int> unreadMessageCounts,
    @Default(0) int unreadPrivateTotal,
    @Default(false) bool isLoadingMore,
    @Default(null) int? currentConversationId,
    @Default(null) int? currentReceiverId,
  }) = _PrivateMessageState;
}
