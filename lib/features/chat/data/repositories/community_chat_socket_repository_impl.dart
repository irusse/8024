import 'package:injectable/injectable.dart';
import 'package:neighbours/features/chat/data/models/message/message_model.dart';
import 'package:neighbours/features/chat/data/socket/chat_socket.dart';
import 'package:neighbours/features/chat/domain/entities/message/message_entity.dart';
import 'package:neighbours/features/chat/domain/repositories/community_chat_socket_repository.dart';

@Singleton(as: CommunityChatSocketRepository)
class CommunityChatSocketRepositoryImpl
    implements CommunityChatSocketRepository {
  final ChatSocket _chatSocket;

  CommunityChatSocketRepositoryImpl(this._chatSocket);

  @override
  void join(int communityId) {
    _chatSocket.joinRoom('joinCommunity', communityId);
  }

  @override
  void leave(int communityId) =>
      _chatSocket.leaveRoom('leaveCommunity', communityId);

  @override
  void sendMessage(int communityId, String text) {
    _chatSocket.emit('sendCommunityMessage', {
      'communityId': communityId,
      'message': {'text': text},
    });
  }

  @override
  void listenMessages(Function(MessageEntity) onNewMessage) {
    _chatSocket.on('newCommunityMessage', (data) {
      onNewMessage(MessageModel.fromJson(data).toEntity());
    });
  }
}
