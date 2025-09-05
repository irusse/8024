import 'package:injectable/injectable.dart';
import 'package:neighbours/features/chat/domain/entities/message/message_entity.dart';
import 'package:neighbours/features/chat/domain/repositories/chat_socket_repository.dart';
import '../datasources/chat_socket_datasource.dart';

@Singleton(as: ChatSocketRepository)
class ChatSocketRepositoryImpl implements ChatSocketRepository {
  final ChatSocketDataSource _chatSocketDataSource;

  ChatSocketRepositoryImpl(this._chatSocketDataSource);

  @override
  void joinEvent(int eventId) {
    _chatSocketDataSource.joinEvent(eventId);
  }

  @override
  void leaveEvent(int eventId) {
    _chatSocketDataSource.leaveEvent(eventId);
  }

  @override
  void sendMessage(int eventId, String message) {
    _chatSocketDataSource.sendMessage(eventId, message);
  }

  @override
  void listenAllMessages(Function(MessageEntity message) onMessage) {
    _chatSocketDataSource
        .listenToNewMessages((message) => onMessage(message.toEntity()));
  }

  @override
  Future<void> initialize() async {
    await _chatSocketDataSource.initializeSocket();
  }
}
