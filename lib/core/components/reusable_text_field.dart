import 'package:flutter/material.dart';
import 'package:neighbours/core/components/custom_text_field.dart';
import 'package:neighbours/core/constants/ui_constants.dart';
import 'package:neighbours/core/extensions/context_ext.dart';

class ReusableTextField extends StatelessWidget {
  final TextEditingController controller;
  final String hintText;
  final String? errorText;
  final bool readOnly;
  final TextInputType? keyboardType;
  final VoidCallback? onTap;
  final void Function(String)? onChange;
  final int? maxLines;

  const ReusableTextField({
    super.key,
    required this.controller,
    required this.hintText,
    this.errorText,
    this.readOnly = false,
    this.keyboardType,
    this.onChange,
    this.onTap,
    this.maxLines,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          height: maxLines != null && maxLines! > 1 
              ? null 
              : UIConstants.defaultTextFieldHeight,
          child: CustomTextField(
            controller: controller,
            readOnly: readOnly,
            onChanged: onChange,
            keyboardType: keyboardType,
            onTap: onTap,
            hintText: hintText,
            enabled: true,
            textStyle: context.text.bodyMedium,
            borderVisible: true,
            maxLines: maxLines,
          ),
        ),
        if (errorText != null)
          Padding(
            padding: const EdgeInsets.only(left: 4, top: 2),
            child: Text(
              errorText!,
              style: context.text.bodySmall
                  .copyWith(color: context.color.basicRed),
            ),
          ),
      ],
    );
  }
}
