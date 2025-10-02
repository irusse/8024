import 'package:neighbours/features/chat/domain/entities/message/message_entity.dart';

abstract class PrivateChatSocketRepository {
  void join(int conversationId);

  void leave(int conversationId);

  void sendMessage({
    int? conversationId,
    int? receiverId,
    required String text,
    Function(int conversationId)? onConversationCreated,
  });

  void listenMessages(Function(MessageEntity) onNewMessage);

  void enableAutoRead(int conversationId);

  void disableAutoRead(int conversationId);
}
