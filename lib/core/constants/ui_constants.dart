import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:neighbours/core/extensions/context_ext.dart';

class UIConstants {
  static const double defaultHorizontalPadding = 16.0;
  static const double defaultTextFieldHeight = 45;
  static const EdgeInsetsGeometry defaultTextFieldPadding =
      EdgeInsets.symmetric(horizontal: 12, vertical: 12);
  static const defaultAnimationDuration = Duration(milliseconds: 300);

  static Border getDefaultBorder(BuildContext context, bool? isActive) {
    return Border.all(
      width: 1.2,
      color: isActive != null
          ? !isActive
              ? context.color.secondary
              : context.color.primary
          : context.color.secondary,
    );
  }

  static double calculateFieldWidth(double maxWidth, int codeLength) {
    const gap = 6.0;
    final calculatedWidth = (maxWidth - gap * (codeLength - 1)) / codeLength;
    return calculatedWidth.clamp(40.0, 60.0);
  }
}