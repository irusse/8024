import 'package:neighbours/features/chat/domain/entities/message/message_entity.dart';

abstract class EventChatSocketRepository {
  void join(int eventId);

  void leave(int eventId);

  void sendMessage(int eventId, String text);

  void listenMessages(Function(MessageEntity) onNewMessage);

  void enableAutoRead(int eventId);

  void disableAutoRead(int eventId);
}
