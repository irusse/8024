import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:neighbours/core/extensions/context_ext.dart';
import 'package:neighbours/core/state/api_state.dart';
import 'package:neighbours/features/chat/presentation/cubits/private_chat/private_chat_cubit.dart';
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
  late PrivateChatCubit _privateChatCubit;

  @override
  void initState() {
    super.initState();

    _privateChatCubit = context.read<PrivateChatCubit>();
    _scrollController.addListener(_onScroll);

    // Если есть conversationId, загружаем сообщения
    if (widget.conversationId != null) {
      _privateChatCubit.fetchPrivateMessages(widget.conversationId!);
      _privateChatCubit.joinConversation(widget.conversationId!);
      _privateChatCubit.setCurrentChat(widget.conversationId);

      // Отмечаем сообщения как прочитанные
      if (_privateChatCubit
              .getUnreadCountForConversation(widget.conversationId!) !=
          0) {
        _privateChatCubit.markPrivateMessagesAsRead(widget.conversationId!);
      }
    } else if (widget.receiverId != null) {
      _privateChatCubit.fetchPrivateMessages(widget.receiverId!);
      // Для новых бесед устанавливаем receiverId и подготавливаем соединение
      _privateChatCubit.setCurrentChat(null);
      _privateChatCubit.setCurrentReceiverId(widget.receiverId);
    }

    // Настраиваем прослушивание сообщений
    _privateChatCubit.listenPrivateMessages();
  }

  void _onScroll() {
    final pos = _scrollController.position;
    const threshold = 120.0;
    // при reverse:true "верх" -> maxScrollExtent
    if (pos.pixels >= pos.maxScrollExtent - threshold) {
      if (widget.conversationId != null &&
          _privateChatCubit.state.hasMoreMessages &&
          !_privateChatCubit.state.isLoadingMore) {
        _privateChatCubit.loadMoreMessages(widget.conversationId!);
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

    // Используем conversationId из widget или из состояния cubit
    final conversationId =
        widget.conversationId ?? _privateChatCubit.state.currentConversationId;
    // Используем receiverId из widget или из состояния cubit
    final receiverId =
        widget.receiverId ?? _privateChatCubit.state.currentReceiverId;

    _privateChatCubit.sendMessage(
      conversationId: conversationId,
      receiverId: receiverId,
      text: text,
    );

    _messageController.clear();
  }

  @override
  void dispose() {
    _privateChatCubit.setCurrentChat(null);
    _privateChatCubit.setCurrentReceiverId(null);
    _scrollController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<PrivateChatCubit, PrivateChatState>(
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
                  .select((PrivateChatCubit cubit) => cubit.state.messages),
              controller: _scrollController,
              isLoading: context.select((PrivateChatCubit cubit) =>
                  cubit.state.fetchMessagesState.isLoading),
              isLoadingMore: context.select(
                  (PrivateChatCubit cubit) => cubit.state.isLoadingMore),
            ),
          ),
          MessageInput(
            messageController: _messageController,
            sendMessage: _sendMessage,
            isLoading: context.select((PrivateChatCubit cubit) =>
                cubit.state.sendMessageState.isLoading),
          ),
        ],
      ),
    );
  }
}
