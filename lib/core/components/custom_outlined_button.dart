import 'package:flutter/material.dart';
import 'package:neighbours/core/components/custom_button.dart';
import 'package:neighbours/core/extensions/context_ext.dart';

class CustomOutlinedButton extends StatelessWidget {
  final VoidCallback onPressed;
  final String text;
  final IconData? iconData;
  final double verticalPadding;
  final bool isLoading;

  const CustomOutlinedButton(
      {super.key,
      required this.onPressed,
      required this.text,
      this.iconData,
      this.isLoading = false,
      this.verticalPadding = 16});

  @override
  Widget build(BuildContext context) {
    return CustomButton(
      onPressed: onPressed,
      isLoading: isLoading,
      padding: EdgeInsets.symmetric(vertical: verticalPadding),
      label: Text(
        text,
        style: context.text.bodyLarge.copyWith(color: context.color.primary),
      ),
      icon: iconData != null
          ? Icon(
              iconData,
              color: context.color.primary,
            )
          : null,
      style: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: context.color.primary, width: 1)),
    );
  }
}
