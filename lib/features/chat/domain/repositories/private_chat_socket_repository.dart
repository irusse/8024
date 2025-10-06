import 'package:neighbours/features/chat/domain/entities/message/message_entity.dart';

abstract class PrivateChatSocketRepository {
  void join(int receiverId);

  void leave(int receiverId);

  void sendMessage({
    required int receiverId,
    required String text,
  });

  void listenMessages(Function(MessageEntity) onNewMessage);

  void enableAutoRead(int receiverId);

  void disableAutoRead(int receiverId);
}
