import 'package:flutter/material.dart';
import 'package:neighbours/core/extensions/context_ext.dart';

class CustomLabel extends StatelessWidget {
  final String text;
  final bool isRequired;

  const CustomLabel({super.key, required this.text, this.isRequired = false});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: RichText(
        text: TextSpan(
          text: text,
          style: context.text.bodyMedium.copyWith(color: context.color.secondaryText),
          children: [
            if (isRequired)
              TextSpan(
                text: ' *',
                style: context.text.bodyMedium.copyWith(
                  color: context.color.basicRed,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
