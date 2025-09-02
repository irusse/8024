import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart'
    show MaskTextInputFormatter;
import 'package:neighbours/core/extensions/context_ext.dart';
import 'package:neighbours/features/auth/presentation/ui-models/country_phone_spec.dart';

import '../../../../core/components/custom_gap.dart';
import '../../../../core/constants/ui_constants.dart';
import '../cubits/auth/auth_cubit.dart';

class PhoneNumberTextField extends StatefulWidget {
  final CountryPhoneSpec country;

  const PhoneNumberTextField({super.key, required this.country});

  @override
  State<PhoneNumberTextField> createState() => _PhoneNumberTextFieldState();
}

class _PhoneNumberTextFieldState extends State<PhoneNumberTextField> {
  final FocusNode _focusNode = FocusNode();
  late final TextEditingController _controller;
  late MaskTextInputFormatter _formatter;

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(() {
      setState(() {});
    });
    _controller = TextEditingController();
    _formatter = MaskTextInputFormatter(mask: widget.country.mask);
  }

  @override
  void didUpdateWidget(covariant PhoneNumberTextField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.country.mask != widget.country.mask) {
      _controller.value = _formatter.updateMask(mask: widget.country.mask);
      _onChanged();
    }
  }

  @override
  void dispose() {
    _focusNode.dispose();
    _controller.dispose();
    super.dispose();
  }

  void _onChanged() {
    final digits = _formatter.getUnmaskedText();
    final isFilled = _formatter.isFill();
    context.read<AuthCubit>().onPhoneInputChanged(
          digits: digits,
          isFilled: isFilled,
        );
  }

  void _clear() {
    _controller.clear();
    _formatter.clear();
    _onChanged();
  }

  @override
  Widget build(BuildContext context) {
    final country = widget.country;
    return BlocBuilder<AuthCubit, AuthState>(
      builder: (context, state) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          height: 48,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: UIConstants.getDefaultBorder(context, _focusNode.hasFocus),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.only(right: 10),
                decoration: BoxDecoration(
                  border: Border(
                    right:
                        BorderSide(color: context.color.secondary, width: 2.0),
                  ),
                ),
                child: Text(
                  "+${country.dialCode}",
                  style: context.text.bodyMedium.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              const HorizontalGap(8),
              Expanded(
                child: BlocListener<AuthCubit, AuthState>(
                  listenWhen: (prev, curr) => prev.country != curr.country,
                  listener: (context, state) => _clear(),
                  child: TextField(
                    controller: _controller,
                    keyboardType: TextInputType.number,
                    onChanged: (vak) => _onChanged(),
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                      _formatter,
                    ],
                    cursorColor: context.color.primary,
                    decoration: const InputDecoration(
                      isDense: true,
                      contentPadding: EdgeInsets.symmetric(vertical: 0),
                      border: InputBorder.none,
                    ),
                    // focusNode: _focusNode,
                    style: context.text.bodyMedium.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
