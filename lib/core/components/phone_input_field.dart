import 'package:flutter/material.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';
import 'package:neighbours/core/components/custom_text_field.dart';
import 'package:neighbours/core/extensions/context_ext.dart';

class PhoneInputField extends StatefulWidget {
  final TextEditingController controller;

  const PhoneInputField({super.key, required this.controller});

  @override
  State<PhoneInputField> createState() => _PhoneInputFieldState();
}

class _PhoneInputFieldState extends State<PhoneInputField> {
  late final MaskTextInputFormatter maskFormatter;

  @override
  void initState() {
    super.initState();
    maskFormatter = MaskTextInputFormatter(
      mask: '(###) ###-##-##',
      filter: {"#": RegExp(r'[0-9]')},
      type: MaskAutoCompletionType.lazy,
    );
  }

  @override
  Widget build(BuildContext context) {
    return CustomTextField(
      controller: widget.controller,
      inputFormatters: [maskFormatter],
      keyboardType: TextInputType.phone,
      borderVisible: true,
      textStyle: context.text.bodyMedium,
      hintText: '(___) ___-__-__',
      prefix: Text(
        '+7 ',
        style: context.text.bodyMedium,
      ),
    );
  }

  String getOnlyDigits() {
    return maskFormatter.getUnmaskedText();
  }
}
