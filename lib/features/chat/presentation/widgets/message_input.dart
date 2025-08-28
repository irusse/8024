import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:neighbours/core/cubits/chat/chat_cubit.dart';
import 'package:neighbours/core/extensions/context_ext.dart';
import 'package:neighbours/core/state/api_state.dart';

class MessageInput extends StatelessWidget {
  final TextEditingController messageController;
  final VoidCallback sendMessage;

  const MessageInput(
      {super.key, required this.sendMessage, required this.messageController});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ChatCubit, ChatState>(
      builder: (context, state) {
        return Container(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: messageController,
                  decoration: InputDecoration(
                    hintStyle: context.text.bodyMedium
                        .copyWith(color: context.color.secondaryText),
                    hintText: 'Введите сообщение...',
                    enabledBorder: OutlineInputBorder(
                      borderRadius: const BorderRadius.all(Radius.circular(24)),
                      borderSide: BorderSide(
                        color: context.color.secondaryText, // обычный цвет
                        width: 1,
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: const BorderRadius.all(Radius.circular(24)),
                      borderSide: BorderSide(
                        color: context.color.primary,
                        width: 1,
                      ),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                  ),
                  maxLines: null,
                  style: context.text.bodyMedium,
                  cursorColor: context.color.primary,
                  textInputAction: TextInputAction.send,
                  onSubmitted: (_) => sendMessage(),
                ),
              ),
              const SizedBox(width: 8),
              Container(
                decoration: BoxDecoration(
                  color: context.color.primary,
                  shape: BoxShape.circle,
                ),
                child: IconButton(
                  onPressed:
                      state.sendMessageState.isLoading ? null : sendMessage,
                  icon: state.sendMessageState.isLoading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor:
                                AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : const Icon(
                          Icons.send,
                          color: Colors.white,
                        ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
