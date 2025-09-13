import 'package:flutter/material.dart';
import 'package:neighbours/core/extensions/context_ext.dart';
class DragHandle extends StatelessWidget {
  const DragHandle({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: 56,
        height: 3,
        decoration: BoxDecoration(
          color: context.color.tertiary,
          borderRadius: BorderRadius.circular(2),
        ),
      ),
    );
  }
}
