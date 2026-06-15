import 'package:injectable/injectable.dart';
import 'package:neighbours/core/logging/logger.dart';
import 'package:neighbours/features/chat/data/models/message/message_model.dart';
import 'package:neighbours/features/chat/data/socket/chat_socket.dart';
import 'package:neighbours/features/chat/domain/entities/message/message_entity.dart';
import 'package:neighbours/features/chat/domain/repositories/private_chat_socket_repository.dart';

@Singleton(as: PrivateChatSocketRepository)
class PrivateChatSocketRepositoryImpl implements PrivateChatSocketRepository {
  final ChatSocket _chatSocket;

  PrivateChatSocketRepositoryImpl(this._chatSocket);

  @override
  void sendMessage({
    required int receiverId,
    required String text,
    Function(int conversationId)? onConversationCreated,
  }) {
    final Map<String, dynamic> messageData = {'text': text};

    messageData['receiverId'] = receiverId;

    // Ожидаем, что сервер вернет conversationId в ответе
    _chatSocket.emit('private:sendMessage', messageData);
  }

  @override
  void listenMessages(Function(MessageEntity) onNewMessage) {
    _chatSocket.on('private:message', (data) {
      try {
        AppLogger.info("New private message received");
        AppLogger.info(data.toString());
        onNewMessage(MessageModel.fromJson(data).toEntity());
      } catch (e) {
        print(e);
      }
    });
  }

  @override
  void listenMessageRead(Function(dynamic) onMessageRead) {
    _chatSocket.on('private:read', (data) {
      AppLogger.info("📖 Private message read by user:");
      AppLogger.info(data.toString());
      onMessageRead(data);
    });
  }

  @override
  void enableAutoRead(int receiverId) {
    _chatSocket.emit('private:autoReadOn', {'receiverId': receiverId});
  }

  @override
  void disableAutoRead(int receiverId) {
    _chatSocket.emit('private:autoReadOff', {'receiverId': receiverId});
  }
}
