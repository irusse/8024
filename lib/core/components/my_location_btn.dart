import 'package:flutter/material.dart';
import 'package:neighbours/core/extensions/context_ext.dart';

import 'custom_button.dart';

class MyLocationBtn extends StatelessWidget {
  final double? top;
  final double? bottom;

  final VoidCallback onClick;

  const MyLocationBtn(
      {super.key, required this.onClick, this.top, this.bottom});

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: top,
      right: 8,
      bottom: bottom,
      child: CustomButton(
        width: 48,
        height: 48,
        style: BoxDecoration(
            shape: BoxShape.circle, color: context.color.secondary),
        icon: Icon(Icons.my_location, color: context.color.primary),
        onPressed: onClick,
      ),
    );
  }
}
