import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:neighbours/core/extensions/context_ext.dart';
import 'package:neighbours/core/state/api_state.dart';
import 'package:neighbours/features/chat/presentation/cubits/community_chat/community_chat_cubit.dart';
import 'package:neighbours/features/chat/presentation/widgets/message_input.dart';
import 'package:neighbours/features/chat/presentation/widgets/message_list.dart';

class CommunityChatWidget extends StatefulWidget {
  final int communityId;

  const CommunityChatWidget({super.key, required this.communityId});

  @override
  State<CommunityChatWidget> createState() => _CommunityChatWidgetState();
}

class _CommunityChatWidgetState extends State<CommunityChatWidget> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  double _prevMaxExtent = 0;
  late CommunityChatCubit _communityChatCubit;

  @override
  void initState() {
    super.initState();

    _communityChatCubit = context.read<CommunityChatCubit>();
    _communityChatCubit.fetchCommunityMessages(widget.communityId);
    _scrollController.addListener(_onScroll);

    // Присоединяемся к чату сообщества
    _communityChatCubit.join(widget.communityId);

    // Устанавливаем текущий открытый чат
    // Это предотвратит показ уведомлений для сообщений из этого чата
    // и позволит добавлять сообщения в состояние только для этого чата
    _communityChatCubit.setCurrentChat(widget.communityId);

    // Отмечаем сообщения как прочитанные
    if (_communityChatCubit.getUnreadCountForCommunity(widget.communityId) !=
        0) {
      _communityChatCubit.removeCommunityCount(widget.communityId);
    }
  }

  void _onScroll() {
    final pos = _scrollController.position;
    const threshold = 120.0;
    // при reverse:true "верх" -> maxScrollExtent
    if (pos.pixels >= pos.maxScrollExtent - threshold) {
      _communityChatCubit.loadMoreMessages(widget.communityId);
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

    _communityChatCubit.addSocketMessage(widget.communityId, text);
    _messageController.clear();
  }

  @override
  void dispose() {
    _communityChatCubit.setCurrentChat(null);
    _scrollController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<CommunityChatCubit, CommunityChatState>(
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
                  .select((CommunityChatCubit cubit) => cubit.state.messages),
              controller: _scrollController,
              isLoading: context.select((CommunityChatCubit cubit) =>
                  cubit.state.fetchMessagesState.isLoading),
              isLoadingMore: context.select(
                  (CommunityChatCubit cubit) => cubit.state.isLoadingMore),
            ),
          ),
          MessageInput(
            messageController: _messageController,
            sendMessage: _sendMessage,
            isLoading: context.select((CommunityChatCubit cubit) =>
                cubit.state.sendMessageState.isLoading),
          ),
        ],
      ),
    );
  }
}
