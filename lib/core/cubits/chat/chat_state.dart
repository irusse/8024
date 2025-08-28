part of 'chat_cubit.dart';

@freezed
class ChatState with _$ChatState {
  const factory ChatState(
      {@Default([]) List<MessageEntity> messages,
      @Default(ApiState.initial())
      ApiState<List<MessageEntity>> fetchMessagesState,
      @Default(ApiState.initial()) ApiState<MessageEntity> sendMessageState,
      @Default(ApiState.initial()) ApiState<void> fetchUnreadCountsState,
      @Default(ApiState.initial()) ApiState<void> markMessagesAsReadState,
      @Default(1) int currentPage,
      @Default(40) int limit,
      @Default(false) bool hasMoreMessages,
      @Default({}) Map<int, int> unreadMessageCounts,
      @Default(0) int unreadEventsTotal,
      @Default(0) int unreadNotificationsTotal,
      @Default(false) bool isLoadingMore}) = _ChatState;
}
