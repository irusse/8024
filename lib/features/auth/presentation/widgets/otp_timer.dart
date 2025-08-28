import 'package:flutter/material.dart';
import 'package:neighbours/core/extensions/context_ext.dart';

class Countdown extends AnimatedWidget {
  final Animation<int>? animation;

  Countdown({
    super.key,
    this.animation,
  }) : super(listenable: animation!);

  @override
  build(BuildContext context) {
    Duration clockTimer = Duration(seconds: animation!.value);

    String timerText =
        '${clockTimer.inMinutes.remainder(60).toString()}:${clockTimer.inSeconds.remainder(60).toString().padLeft(2, '0')}';

    return Text(
      'Выслать код повторно через $timerText',
      textAlign: TextAlign.center,
      style: context.text.bodyMedium.copyWith(
          color: context.color.secondaryText, fontWeight: FontWeight.w500),
    );
  }
}
