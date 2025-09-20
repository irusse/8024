import 'package:flutter/material.dart';
import 'package:neighbours/core/components/custom_svg.dart';

class IconTextSpan extends StatelessWidget {
  final String text;
  final Color iconColor;
  final double iconSize;
  final double spacing;
  final IconData? icon;
  final TextStyle? textStyle;
  final String? iconPath;
  final int maxLines;

  const IconTextSpan(
      {super.key,
      required this.text,
      required this.iconColor,
      required this.textStyle,
      this.iconPath,
      this.icon,
      this.iconSize = 24,
      this.spacing = 4,
      this.maxLines = 2})
      : assert(
          icon != null || iconPath != null,
          'Either `icon` or `iconPath` must be provided.',
        );

  @override
  Widget build(BuildContext context) {
    Widget iconWidget;
    if (icon != null) {
      iconWidget = Icon(icon, size: iconSize, color: iconColor);
    } else {
      iconWidget = CustomSvg(
        asset: iconPath!,
        width: iconSize,
        height: iconSize,
        color: iconColor,
      );
    }

    return RichText(
      maxLines: maxLines,
      overflow: TextOverflow.ellipsis,
      text: TextSpan(
        children: [
          WidgetSpan(
            alignment: PlaceholderAlignment.middle,
            child: iconWidget,
          ),
          WidgetSpan(
            child: SizedBox(width: spacing),
          ),
          TextSpan(
            text: text,
            style: textStyle,
          ),
        ],
      ),
    );
  }
}
