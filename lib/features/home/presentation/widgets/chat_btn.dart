import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:neighbours/core/components/custom_svg.dart';
import 'package:neighbours/core/extensions/context_ext.dart';
import 'package:neighbours/core/router/app_routes.dart';
import 'package:neighbours/features/chat/presentation/cubits/chat/chat_cubit.dart';

import '../../../../core/constants/assets.dart';

class ChatButton extends StatelessWidget {
  const ChatButton({super.key});

  @override
  Widget build(BuildContext context) {
    final haveUnreadMessages =
        context.select<ChatCubit, bool>((cubit) => cubit.hasUnreadMessages);
    return GestureDetector(
      onTap: () => context.push(AppRoutePath.chatListPage),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            height: 48,
            width: 48,
            decoration: BoxDecoration(
              color: context.color.primary.withValues(alpha: 0.8),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CustomSvg(asset: Assets.icons.messages, color: Colors.white),
                const SizedBox(height: 3),
                Text(
                  'ЧАТ',
                  style: context.text.labelLarge.copyWith(
                    fontWeight: FontWeight.w700,
                    fontSize: 11,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
          if (haveUnreadMessages)
            Positioned(
              top: 6,
              right: 8,
              child: Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: context.color.basicRed,
                  shape: BoxShape.circle,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
