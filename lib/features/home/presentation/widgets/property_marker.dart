import 'package:flutter/material.dart';
import 'package:neighbours/core/extensions/context_ext.dart';

class PropertyMarker extends StatelessWidget {
  final bool isVerified;

  const PropertyMarker({super.key, this.isVerified = false});

  @override
  Widget build(BuildContext context) => IgnorePointer(
        child: Center(
          child: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: context.color.primary.withValues(alpha: 0.73),
              shape: BoxShape.circle,
              border: Border.all(
                color: context.color.primary,
                width: 4,
              ),
            ),
          ),
        ),
      );
}
