import 'package:flutter/material.dart';
import 'package:neighbours/core/components/custom_button.dart';
import 'package:neighbours/core/extensions/context_ext.dart';

class PrimaryButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final double verticalPadding;
  final bool isEnabled;
  final bool isLoading;
  final Color? backgroundColor;
  final FontWeight? fontWeight;

  const PrimaryButton(
      {super.key,
      required this.text,
      required this.onPressed,
      this.isEnabled = true,
      this.isLoading = false,
      this.backgroundColor,
      this.verticalPadding = 16,
      this.fontWeight});

  @override
  Widget build(BuildContext context) {
    return CustomButton(
      isEnabled: isEnabled,
      isLoading: isLoading,
      label: Text(
        text,
        style: context.text.bodyLarge.copyWith(
            fontWeight: fontWeight ?? FontWeight.w500, color: Colors.white),
      ),
      onPressed: onPressed,
      style: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          color: backgroundColor ?? context.color.primary),
      padding: EdgeInsets.symmetric(vertical: verticalPadding),
    );
  }
}
