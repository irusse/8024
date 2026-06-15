import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:neighbours/core/extensions/context_ext.dart';

import '../../../../core/services/clipboard_service.dart';

class LabelValueText extends StatelessWidget {
  final String label;
  final String value;
  final Color? valueColor;
  final TextStyle? textStyle;
  final bool copyOnClick;
  final VoidCallback? onClick;

  const LabelValueText(
      {super.key,
      required this.label,
      required this.value,
      this.valueColor,
      this.textStyle,
      this.onClick,
      this.copyOnClick = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.centerLeft,
      child: Text.rich(
        TextSpan(
          children: [
            TextSpan(
              text: '$label: ',
              style: (textStyle ?? context.text.bodyLarge)
                  .copyWith(fontWeight: FontWeight.w500),
            ),
            TextSpan(
              text: value,
              style: (textStyle ?? context.text.bodyLarge).copyWith(
                fontWeight: FontWeight.w500,
                color: valueColor ?? context.color.primary,
              ),
              recognizer: TapGestureRecognizer()
                ..onTap = onClick != null
                    ? onClick
                    : () {
                        if (copyOnClick) {
                          ClipboardService.copyToClipboard(
                            context: context,
                            text: value,
                          );
                        }
                      },
            ),
          ],
        ),
      ),
    );
  }
}
