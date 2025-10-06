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
  void join(int conversationId) {
    _chatSocket.joinRoom('private:join', conversationId);
  }

  @override
  void leave(int conversationId) =>
      _chatSocket.leaveRoom('private:leave', conversationId);

  @override
  void sendMessage({
    required int receiverId,
    required String text,
    Function(int conversationId)? onConversationCreated,
  }) {
    final Map<String, dynamic> messageData = {'text': text};

    messageData['receiverId'] = receiverId;
    AppLogger.info('Creating new conversation with user: $receiverId');

    _chatSocket.emitWithAck('private:sendMessage', messageData, (response) {
      AppLogger.info('Server response for new conversation: $response');

      // Ожидаем, что сервер вернет conversationId в ответе
      if (response != null && response is Map<String, dynamic>) {
        final newConversationId = response['conversationId'];
        if (newConversationId != null && onConversationCreated != null) {
          AppLogger.info(
              'New conversation created with ID: $newConversationId');
          AppLogger.info(response.toString());
          onConversationCreated(newConversationId);
        }
      }
    });
  }

  @override
  void listenMessages(Function(MessageEntity) onNewMessage) {
    _chatSocket.on('private:message', (data) {
      AppLogger.info("New private message received");
      AppLogger.info(data.toString());
      onNewMessage(MessageModel.fromJson(data).toEntity());
    });
  }

  @override
  void enableAutoRead(int conversationId) {
    _chatSocket.emit('private:autoReadOn', {'conversationId': conversationId});
  }

  @override
  void disableAutoRead(int conversationId) {
    _chatSocket.emit('private:autoReadOff', {'conversationId': conversationId});
  }
}
