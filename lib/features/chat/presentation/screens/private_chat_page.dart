import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:neighbours/core/components/default_circle_avatar.dart';
import 'package:neighbours/features/chat/presentation/widgets/private_chat_widget.dart';
import 'package:neighbours/core/components/default_app_bar.dart';
import 'package:neighbours/core/components/custom_gap.dart';
import 'package:neighbours/core/extensions/context_ext.dart';
import 'package:neighbours/features/chat/presentation/cubits/private_chat/private_chat_cubit.dart';

class PrivateChatPage extends StatefulWidget {
  final int interlocutorId;
  final String interlocutorName;
  final String? interlocutorAvatarUrl;

  const PrivateChatPage({
    super.key,
    required this.interlocutorId,
    required this.interlocutorName,
    this.interlocutorAvatarUrl,
  });

  @override
  State<PrivateChatPage> createState() => _PrivateChatPageState();
}

class _PrivateChatPageState extends State<PrivateChatPage> {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PrivateChatCubit, PrivateChatState>(
      builder: (context, state) {
        // Получаем имя из кубита, если переданное имя пустое или равно 'Пользователь'
        final effectiveName = _getEffectiveInterlocutorName(context);
        final effectiveAvatar = _getEffectiveInterlocutorAvatar(context);

        return Scaffold(
          appBar: DefaultAppBar(
            showBackButton: true,
            titleWidget:
                _buildAppBarContent(context, effectiveName, effectiveAvatar),
            height: 80,
          ),
          body: PrivateChatWidget(
            interlocutorId: widget.interlocutorId,
          ),
        );
      },
    );
  }

  Widget _buildAppBarContent(
      BuildContext context, String name, String? avatarUrl) {
    return Expanded(
        child: Row(
      children: [
        DefaultCircleAvatar(
          name: name,
          id: widget.interlocutorId,
          radius: 24,
          textStyle: context.text.bodyLarge,
          url: avatarUrl,
        ),
        const HorizontalGap(12),
        Flexible(
          child: Text(
            name,
            style: context.text.titleSmall,
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
          ),
        )
      ],
    ));
  }

  /// Получает эффективное имя собеседника (из кубита, если переданное имя пустое)
  String _getEffectiveInterlocutorName(BuildContext context) {
    // Если переданное имя пустое или равно 'Пользователь', пытаемся получить из кубита
    if (widget.interlocutorName.isEmpty ||
        widget.interlocutorName == 'Пользователь') {
      final cubit = context.read<PrivateChatCubit>();
      final nameFromCubit = cubit.getInterlocutorName(widget.interlocutorId);
      return nameFromCubit ?? widget.interlocutorName;
    }
    return widget.interlocutorName;
  }

  /// Получает эффективный аватар собеседника (из кубита, если переданный аватар пустой)
  String? _getEffectiveInterlocutorAvatar(BuildContext context) {
    // Если переданный аватар пустой, пытаемся получить из кубита
    if (widget.interlocutorAvatarUrl == null ||
        widget.interlocutorAvatarUrl!.isEmpty) {
      final cubit = context.read<PrivateChatCubit>();
      return cubit.getInterlocutorAvatar(widget.interlocutorId);
    }
    return widget.interlocutorAvatarUrl;
  }
}
