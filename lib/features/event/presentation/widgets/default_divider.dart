import 'package:flutter/material.dart';
import 'package:neighbours/core/extensions/context_ext.dart';

class DefaultDivider extends StatelessWidget {
  const DefaultDivider({super.key});

  @override
  Widget build(BuildContext context) {
    return Divider(
      color: context.color.secondary,
      height: 1,
    );
  }
}
