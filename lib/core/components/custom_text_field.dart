import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:neighbours/core/extensions/context_ext.dart';

import '../constants/ui_constants.dart';

class CustomTextField extends StatefulWidget {
  final FocusNode? focus;
  final bool readOnly;
  final TextEditingController? controller;
  final String? hintText;
  final Function(String)? onChanged;
  final EdgeInsets? padding;
  final bool borderVisible;
  final List<TextInputFormatter>? inputFormatters;
  final TextInputType? keyboardType;
  final VoidCallback? onTap;
  final bool enabled;
  final int? maxLength;
  final String? counterText;
  final bool autoFocus;
  final TextStyle? textStyle;
  final TextAlign textAlign;
  final ScrollController? scrollController;
  final Widget? prefix;
  final int? maxLines;

  const CustomTextField(
      {super.key,
      this.hintText,
      this.padding,
      required this.controller,
      this.onChanged,
      this.readOnly = false,
      this.inputFormatters,
      this.keyboardType,
      this.prefix,
      this.textAlign = TextAlign.left,
      this.focus,
      this.maxLength,
      this.scrollController,
      this.onTap,
      this.autoFocus = false,
      this.enabled = true,
      this.counterText,
      this.textStyle,
      this.borderVisible = false,
      this.maxLines});

  @override
  State<CustomTextField> createState() => _CustomTextFieldState();
}

class _CustomTextFieldState extends State<CustomTextField> {
  late ValueNotifier<bool> _isFocusedNotifier;
  late FocusNode _focusNode;

  @override
  void initState() {
    super.initState();
    _focusNode = widget.focus ?? FocusNode();
    _isFocusedNotifier = ValueNotifier(_focusNode.hasFocus);
    _focusNode.addListener(_handleFocusChange);

    if (widget.autoFocus) _focusNode.requestFocus();
  }

  @override
  void dispose() {
    _focusNode.removeListener(_handleFocusChange);
    _isFocusedNotifier.dispose();
    if (widget.focus == null) _focusNode.dispose();

    super.dispose();
  }

  void _handleFocusChange() {
    if (mounted) {
      _isFocusedNotifier.value = _focusNode.hasFocus;
    }
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: _isFocusedNotifier,
      builder: (context, isFocused, child) {
        return Container(
          padding: widget.padding ??
              const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            border: widget.borderVisible
                ? UIConstants.getDefaultBorder(context, isFocused)
                : null,
            color: !widget.enabled || widget.readOnly
                ? context.color.secondary
                : null,
          ),
          child: child,
        );
      },
      child: Row(
        children: [
          if (widget.prefix != null) widget.prefix!,
          Expanded(
            child: TextField(
              onTapOutside: (event) =>
                  FocusManager.instance.primaryFocus?.unfocus(),
              scrollController: widget.scrollController,
              autofocus: widget.autoFocus,
              onTap: widget.onTap,
              maxLength: widget.maxLength,
              focusNode: _focusNode,
              enabled: widget.enabled,
              onChanged: widget.onChanged,
              textAlign: widget.textAlign,
              readOnly: widget.readOnly,
              controller: widget.controller,
              cursorColor: context.color.primary,
              style: widget.textStyle ??
                  context.text.bodyMedium.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
              keyboardType: widget.keyboardType,
              maxLines: widget.maxLines,
              inputFormatters: widget.inputFormatters ??
                  (widget.keyboardType ==
                          const TextInputType.numberWithOptions(decimal: true)
                      ? []
                      : null),
              decoration: InputDecoration(
                contentPadding: EdgeInsets.zero,
                counterText: widget.counterText,
                disabledBorder: InputBorder.none,
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                hintText: widget.hintText,
                hintStyle: TextStyle(color: context.color.secondaryText),
                isDense: true,
              ),
            ),
          )
        ],
      ),
    );
  }
}
