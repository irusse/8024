import 'package:flutter/material.dart';
import 'package:neighbours/core/components/custom_gap.dart';
import 'package:neighbours/core/components/custom_svg.dart';
import 'package:neighbours/core/extensions/context_ext.dart';

class MenuListItem extends StatelessWidget {
  final IconData? icon;
  final String? iconPath;
  final String text;
  final VoidCallback onTap;
  final Color? iconColor;
  final Color? textColor;
  final bool showArrow;

  const MenuListItem({
    super.key,
    required this.text,
    required this.onTap,
    this.iconColor,
    this.textColor,
    this.icon,
    this.iconPath,
    this.showArrow = true,
  });

  Widget _buildIcon() {
    if (iconPath != null && iconColor != null) {
      return Container(
        margin: const EdgeInsets.only(right: 16),
        child: CustomSvg(asset: iconPath!, color: iconColor!),
      );
    }

    if (icon != null) {
      return Container(
          margin: const EdgeInsets.only(right: 16),
          child: Icon(icon, color: iconColor, size: 24));
    }
    return const HorizontalGap(40);
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 16),
        child: Row(
          children: [
            _buildIcon(),
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
