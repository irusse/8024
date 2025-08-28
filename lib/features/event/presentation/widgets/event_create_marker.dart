import 'package:flutter/material.dart';
import 'package:neighbours/core/extensions/context_ext.dart';

class EventCreateMarker extends StatelessWidget {
  const EventCreateMarker({super.key});

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Center(
        child: Container(
          alignment: Alignment.center,
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: context.color.primary.withValues(alpha: 0.8),
            shape: BoxShape.circle,
            border: Border.all(
              color: Colors.white,
              width: 3,
            ),
          ),
        ),
      ),
    );
  }
}
