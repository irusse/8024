import 'package:injectable/injectable.dart';
import 'package:neighbours/features/chat/data/models/message/message_model.dart';
import 'package:neighbours/features/chat/data/socket/chat_socket.dart';
import 'package:neighbours/features/chat/domain/entities/message/message_entity.dart';
import 'package:neighbours/features/chat/domain/repositories/event_chat_socket_repository.dart';

@Singleton(as: EventChatSocketRepository)
class EventChatRepositoryImpl implements EventChatSocketRepository {
  final ChatSocket _chatSocket;

  EventChatRepositoryImpl(this._chatSocket);

  @override
  void join(int eventId) => _chatSocket.joinRoom('joinEvent', eventId);

  @override
  void leave(int eventId) => _chatSocket.leaveRoom('leaveEvent', eventId);

  @override
  void sendMessage(int eventId, String text) {
    _chatSocket.emit('sendMessage', {
      'eventId': eventId,
      'message': {'text': text},
    });
  }

  @override
  void listenMessages(Function(MessageEntity) onNewMessage) {
    _chatSocket.on('newMessage', (data) {
      onNewMessage(MessageModel.fromJson(data).toEntity());
    });
  }
}
