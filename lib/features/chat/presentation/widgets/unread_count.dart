import 'package:flutter/material.dart';
import 'package:neighbours/core/extensions/context_ext.dart';

class UnreadCount extends StatelessWidget {
  final int count;

  const UnreadCount({super.key, required this.count});

  @override
  Widget build(BuildContext context) {
    if (count == 0) return const SizedBox.shrink();
    return Container(
      width: 24,
      height: 24,
      alignment: Alignment.center,
      decoration:
          BoxDecoration(color: context.color.basicRed, shape: BoxShape.circle),
      constraints: const BoxConstraints(minWidth: 20, minHeight: 20),
      child: Text(
        count > 99 ? '99+' : count.toString(),
        style: context.text.labelLarge.copyWith(
          color: Colors.white,
          fontWeight: FontWeight.w600,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }
}
