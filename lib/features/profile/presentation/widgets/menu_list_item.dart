import 'package:flutter/material.dart';
import 'package:neighbours/core/components/custom_gap.dart';
import 'package:neighbours/core/components/custom_svg.dart';
import 'package:neighbours/core/constants/ui_constants.dart';
import 'package:neighbours/core/extensions/context_ext.dart';

class MenuListItem extends StatelessWidget {
  final IconData? icon;
  final String? iconPath;
  final String text;
  final VoidCallback onTap;
  final Color? iconColor;
  final Color? textColor;
  final bool showArrow;
  final bool showBadge;

  const MenuListItem(
      {super.key,
      required this.text,
      required this.onTap,
      this.iconColor,
      this.textColor,
      this.icon,
      this.iconPath,
      this.showArrow = true,
      this.showBadge = false});

  Widget _buildIcon(BuildContext context) {
    Widget iconWidget;

    if (iconPath != null && iconColor != null) {
      iconWidget = CustomSvg(asset: iconPath!, color: iconColor!);
    } else if (icon != null) {
      iconWidget = Icon(icon, color: iconColor, size: 24);
    } else {
      return const HorizontalGap(40);
    }

    return Container(
      margin: const EdgeInsets.only(right: 16),
      width: 24,
      height: 24,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Center(child: iconWidget),
          if (showBadge)
            Positioned(
              right: 4,
              top: 2,
              child: Container(
                width: 7,
                height: 7,
                decoration: BoxDecoration(
                  color: context.color.basicRed, // цвет бейджа
                  shape: BoxShape.circle,
                ),
              ),
            ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(
            horizontal: UIConstants.defaultHorizontalPadding, vertical: 16),
        child: Row(
          children: [
            _buildIcon(context),
            Expanded(
              child: Text(
                text,
                style: context.text.bodyLarge.copyWith(color: textColor),
              ),
            ),
            if (showArrow)
              Icon(
                Icons.arrow_forward_ios_rounded,
                color: context.color.secondaryText,
                size: 16,
              ),
          ],
        ),
      ),
    );
  }
}
