import 'package:neighbours/core/domain/entities/message/message_entity.dart';

abstract class ChatSocketRepository {
  Future<void> initialize();

  void joinEvent(int eventId);

  void leaveEvent(int eventId);

  void listenAllMessages(Function(MessageEntity message) onMessage);

  void sendMessage(int eventId, String message);
}
