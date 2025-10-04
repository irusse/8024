import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:neighbours/core/extensions/context_ext.dart';
import 'package:neighbours/core/state/api_state.dart';
import 'package:neighbours/features/chat/presentation/cubits/private_message/private_message_cubit.dart';
import 'package:neighbours/features/chat/presentation/widgets/message_input.dart';
import 'package:neighbours/features/chat/presentation/widgets/message_list.dart';

class PrivateChatWidget extends StatefulWidget {
  final int? conversationId;
  final int? receiverId;

  const PrivateChatWidget({
    super.key,
    this.conversationId,
    this.receiverId,
  });

  @override
  State<PrivateChatWidget> createState() => _PrivateChatWidgetState();
}

class _PrivateChatWidgetState extends State<PrivateChatWidget> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  double _prevMaxExtent = 0;
  late PrivateMessageCubit _privateMessageCubit;

  @override
  void initState() {
    super.initState();

    _privateMessageCubit = context.read<PrivateMessageCubit>();
    _scrollController.addListener(_onScroll);

    // Если есть conversationId, загружаем сообщения
    if (widget.conversationId != null) {
      _privateMessageCubit.fetchPrivateMessages(widget.conversationId!);
      _privateMessageCubit.joinConversation(widget.conversationId!);
      _privateMessageCubit.setCurrentChat(widget.conversationId);

      // Отмечаем сообщения как прочитанные
      if (_privateMessageCubit
              .getUnreadCountForConversation(widget.conversationId!) !=
          0) {
        _privateMessageCubit.markPrivateMessagesAsRead(widget.conversationId!);
      }
    } else {
      // Для новых бесед устанавливаем receiverId
      _privateMessageCubit.setCurrentChat(null);
    }

    // Настраиваем прослушивание сообщений
    _privateMessageCubit.listenPrivateMessages();
  }

  void _onScroll() {
    final pos = _scrollController.position;
    const threshold = 120.0;
    // при reverse:true "верх" -> maxScrollExtent
    if (pos.pixels >= pos.maxScrollExtent - threshold) {
      if (widget.conversationId != null &&
          _privateMessageCubit.state.hasMoreMessages &&
          !_privateMessageCubit.state.isLoadingMore) {
        _privateMessageCubit.loadMoreMessages(widget.conversationId!);
      }
    }
  }

  // сохраняем видимую позицию после догрузки,
  // чтобы контент не «прыгал»
  void _restoreScrollAfterAppend() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        final newMaxExtent = _scrollController.position.maxScrollExtent;
        final scrollOffset = newMaxExtent - _prevMaxExtent;
        if (scrollOffset > 0) {
          _scrollController.animateTo(
            scrollOffset,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOut,
          );
        }
      }
    });
  }

  void _sendMessage() {
    final text = _messageController.text.trim();
    if (text.isEmpty) return;

    _privateMessageCubit.sendMessage(
      conversationId: widget.conversationId,
      receiverId: widget.receiverId,
      text: text,
    );

    _messageController.clear();
  }

  @override
  void dispose() {
    _privateMessageCubit.setCurrentChat(null);
    _scrollController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<PrivateMessageCubit, PrivateMessageState>(
      listenWhen: (p, c) =>
          p.fetchMessagesState != c.fetchMessagesState ||
          p.sendMessageState != c.sendMessageState,
      listener: (context, state) {
        if (state.sendMessageState.isFailure) {
          context.snackbar.error(context, state.sendMessageState.error!);
        }
        if (state.fetchMessagesState.isFailure) {
          context.snackbar.error(context, state.fetchMessagesState.error!);
        }
        if (state.markMessagesAsReadState.isFailure) {
          context.snackbar.error(context, state.markMessagesAsReadState.error!);
        }

        // если это была догрузка (не первый фетч) — восстановим позицию
        final wasLoading = state.fetchMessagesState.isLoading;
        if (!wasLoading && _prevMaxExtent > 0) {
          _restoreScrollAfterAppend();
          _prevMaxExtent = 0;
        }
      },
      child: Column(
        children: [
          Expanded(
            child: MessageList(
              messages: context
                  .select((PrivateMessageCubit cubit) => cubit.state.messages),
              controller: _scrollController,
              isLoading: context.select((PrivateMessageCubit cubit) =>
                  cubit.state.fetchMessagesState.isLoading),
              isLoadingMore: context
                  .select((PrivateMessageCubit cubit) => cubit.state.isLoadingMore),
            ),
          ),
          MessageInput(
            messageController: _messageController,
            sendMessage: _sendMessage,
            isLoading: context.select((PrivateMessageCubit cubit) =>
                cubit.state.sendMessageState.isLoading),
          ),
        ],
      ),
    );
  }
}