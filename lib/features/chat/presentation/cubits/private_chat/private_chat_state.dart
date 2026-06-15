part of 'private_chat_cubit.dart';

@freezed
abstract class PrivateChatState with _$PrivateChatState {
  const factory PrivateChatState({
    @Default([]) List<MessageEntity> messages,
    @Default([]) List<PrivateChatListEntity> conversations,
    @Default(ApiState.initial())
    ApiState<List<MessageEntity>> fetchMessagesState,
    @Default(ApiState.initial())
    ApiState<List<PrivateChatListEntity>> fetchConversationsState,
    @Default(ApiState.initial()) ApiState<void> sendMessageState,
    @Default(ApiState.initial()) ApiState<void> markMessagesAsReadState,
    @Default(1) int currentPage,
    @Default(40) int limit,
    @Default(false) bool hasMoreMessages,
    @Default(false) bool isLoadingMore,
    int? currentConversationId,
  }) = _PrivateChatState;
}
