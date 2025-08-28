import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:neighbours/core/cubits/chat/chat_cubit.dart';
import 'package:neighbours/core/extensions/context_ext.dart';
import 'package:neighbours/core/state/api_state.dart';
import 'package:neighbours/features/chat/presentation/widgets/message_input.dart';
import 'package:neighbours/features/chat/presentation/widgets/message_list.dart';

class ChatWidget extends StatefulWidget {
  final int eventId;

  const ChatWidget({super.key, required this.eventId});

  @override
  State<ChatWidget> createState() => _ChatWidgetState();
}

class _ChatWidgetState extends State<ChatWidget> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  double _prevMaxExtent = 0;
  late ChatCubit _chatCubit;

  @override
  void initState() {
    super.initState();

    _chatCubit = context.read<ChatCubit>();
    _chatCubit.fetchEventMessages(widget.eventId);
    _scrollController.addListener(_onScroll);

    // Присоединяемся к чату события
    _chatCubit.joinEvent(widget.eventId);

    // Устанавливаем текущий открытый чат
    // Это предотвратит показ уведомлений для сообщений из этого чата
    // и позволит добавлять сообщения в состояние только для этого чата
    _chatCubit.setCurrentChat(widget.eventId);

    // Отмечаем сообщения как прочитанные
    _chatCubit.markEventMessagesAsRead(widget.eventId);
  }

  void _onScroll() {
    final pos = _scrollController.position;
    const threshold = 120.0;
    // при reverse:true "верх" -> maxScrollExtent
    if (pos.pixels >= pos.maxScrollExtent - threshold) {
      _chatCubit.loadMoreMessages(widget.eventId);
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

    _chatCubit.addSocketMessage(widget.eventId, text);
    _messageController.clear();
  }

  @override
  void dispose() {
    // Сбрасываем текущий открытый чат
    _chatCubit.setCurrentChat(null);

    _scrollController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<ChatCubit, ChatState>(
      listenWhen: (p, c) =>
          p.fetchMessagesState != c.fetchMessagesState ||
          p.sendMessageState != c.sendMessageState,
      listener: (context, state) {
        if (state.sendMessageState.isFailure) {
          context.snackbar.error(context, state.sendMessageState.error!);
        }
        if (state.fetchMessagesState.isFailure) {
          context.snackbar.error(context, state.sendMessageState.error!);
        }
        if (state.markMessagesAsReadState.isFailure) {
          context.snackbar.error(context, state.sendMessageState.error!);
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
              messages:
                  context.select((ChatCubit cubit) => cubit.state.messages),
              controller: _scrollController,
              isLoading: context.select((ChatCubit cubit) =>
                  cubit.state.fetchMessagesState.isLoading),
              isLoadingMore: context
                  .select((ChatCubit cubit) => cubit.state.isLoadingMore),
            ),
          ),
          MessageInput(
            messageController: _messageController,
            sendMessage: _sendMessage,
          ),
        ],
      ),
    );
  }
}
