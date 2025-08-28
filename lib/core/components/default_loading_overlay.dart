import 'package:flutter/material.dart';
import 'package:neighbours/core/extensions/context_ext.dart';

class DefaultLoadingOverlay extends StatelessWidget {
  final bool transparent;

  const DefaultLoadingOverlay({super.key, this.transparent = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: transparent
          ? Colors.transparent
          : context.color.secondary.withValues(alpha: 0.6),
      child: Center(
        child: CircularProgressIndicator(
          color: context.color.primary,
        ),
      ),
    );
  }
}
