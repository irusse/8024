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
  void join(int receiverId) {
    _chatSocket.joinRoom('private:join', receiverId);
  }

  @override
  void leave(int receiverId) =>
      _chatSocket.leaveRoom('private:leave', receiverId);

  @override
  void sendMessage({
    required int receiverId,
    required String text,
    Function(int conversationId)? onConversationCreated,
  }) {
    final Map<String, dynamic> messageData = {'text': text};

    messageData['receiverId'] = receiverId;
    AppLogger.info('Creating new conversation with user: $receiverId');

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
    _chatSocket.emit('private:sendMessage', messageData);
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
  void enableAutoRead(int receiverId) {
    _chatSocket.emit('private:autoReadOn', {'receiverId': receiverId});
  }

  @override
  void disableAutoRead(int receiverId) {
    _chatSocket.emit('private:autoReadOff', {'receiverId': receiverId});
  }
}
