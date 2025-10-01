import 'package:neighbours/features/chat/domain/entities/message/message_entity.dart';

abstract class CommunityChatSocketRepository {
  void join(int communityId);

  void leave(int communityId);

  void sendMessage(int communityId, String text);

  void listenMessages(Function(MessageEntity) onNewMessage);

  void enableAutoRead(int communityId);

  void disableAutoRead(int communityId);
}
