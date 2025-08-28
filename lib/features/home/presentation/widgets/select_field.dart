import 'package:flutter/material.dart';
import 'package:neighbours/core/constants/ui_constants.dart';
import 'package:neighbours/core/extensions/context_ext.dart';

class SelectField extends StatelessWidget {
  final String label;
  final String value;
  final VoidCallback onTap;
  final IconData? icon;

  const SelectField(
      {super.key,
      required this.label,
      required this.value,
      required this.onTap,
      this.icon});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 45,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
          border: UIConstants.getDefaultBorder(context, false),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              value.isNotEmpty ? value : label,
              style: context.text.bodyLarge.copyWith(
                  color: value.isNotEmpty
                      ? context.color.primaryText
                      : context.color.secondaryText),
            ),
            if (icon != null) Icon(icon, color: context.color.secondaryText),
          ],
        ),
      ),
    );
  }
}
