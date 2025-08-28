import 'package:flutter/material.dart';
import 'package:neighbours/core/extensions/context_ext.dart';

import 'custom_gap.dart';
import 'custom_svg.dart';

class BottomSheetOption extends StatelessWidget {
  final String text;
  final String iconPath;
  final VoidCallback onClick;
  final bool isDelete;

  const BottomSheetOption(
      {super.key,
      required this.text,
      required this.onClick,
      required this.iconPath,
      this.isDelete = false});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onClick,
      child: Container(
        height: 48,
        width: double.infinity,
        color: Colors.transparent,
        child: Row(
          children: [
            CustomSvg(
              asset: iconPath,
              color: isDelete ? context.color.basicRed : context.color.primary,
            ),
            const HorizontalGap(8),
            Text(
              text,
              style: context.text.bodyLarge,
            ),
          ],
        ),
      ),
    );
  }
}
