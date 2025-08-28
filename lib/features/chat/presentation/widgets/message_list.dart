import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:neighbours/core/domain/entities/message/message_entity.dart';
import 'package:neighbours/core/extensions/context_ext.dart';

import '../../../../core/components/custom_gap.dart';
import '../../../../core/cubits/user/user_cubit.dart';
import 'message_item.dart';

class MessageList extends StatelessWidget {
  final ScrollController controller;
  final bool isLoading; // первичная загрузка
  final bool isLoadingMore; // пагинация
  final List<MessageEntity> messages;

  const MessageList({
    super.key,
    required this.messages,
    required this.controller,
    required this.isLoading,
    required this.isLoadingMore,
  });

  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading && messages.isEmpty) {
      return Center(
          child: CircularProgressIndicator(color: context.color.primary));
    }
    if (messages.isEmpty) {
      return Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.chat_bubble_outline,
                  size: 64, color: context.color.secondaryText),
              const VerticalGap(16),
              Text(
                'Нет сообщений',
                style: context.text.bodyLarge
                    .copyWith(color: context.color.secondaryText),
              ),
              const VerticalGap(8),
              Text(
                'Будьте первым, кто напишет!',
                style: context.text.bodyMedium
                    .copyWith(color: context.color.secondaryText),
              ),
            ],
          ),
        ),
      );
    }

    final extra = isLoadingMore ? 1 : 0;

    return ListView.builder(
      controller: controller,
      reverse: true,
      padding: const EdgeInsets.all(16),
      itemCount: messages.length + extra,
      itemBuilder: (context, index) {
        if (isLoadingMore && index == messages.length) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Center(
              child: SizedBox(
                height: 24,
                width: 24,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: context.color.primary,
                ),
              ),
            ),
          );
        }

        final message = messages[index];
        final prevMessage =
            index + 1 < messages.length ? messages[index + 1] : null;

        final needSeparator = prevMessage == null ||
            !_isSameDay(message.createdAt, prevMessage.createdAt);

        return Column(
          children: [
            if (needSeparator) DateSeparator(date: message.createdAt),
            MessageItem(
              message: message,
              userId: context.read<UserCubit>().state.user.id,
            ),
          ],
        );
      },
    );
  }
}

class DateSeparator extends StatelessWidget {
  final DateTime date;

  const DateSeparator({super.key, required this.date});

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    String text;

    if (date.year == now.year &&
        date.month == now.month &&
        date.day == now.day) {
      text = 'Сегодня';
    } else if (date.year == now.year &&
        date.month == now.month &&
        date.day == now.day - 1) {
      text = 'Вчера';
    } else {
      text = DateFormat("dd.MM.yyyy").format(date);
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Center(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          decoration: BoxDecoration(
            color: context.color.secondary,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            text,
            style: context.text.bodySmall.copyWith(
                color: context.color.secondaryText,
                fontWeight: FontWeight.w500),
          ),
        ),
      ),
    );
  }
}
