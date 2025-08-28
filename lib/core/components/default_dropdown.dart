import 'package:flutter/material.dart';
import 'package:neighbours/core/extensions/context_ext.dart';

import '../constants/ui_constants.dart';

class DefaultDropdown<T> extends StatelessWidget {
  final T? value;
  final ValueChanged<T?> onChanged;
  final String? defaultText;
  final List<DropdownMenuItem<T>> items;

  const DefaultDropdown(
      {super.key,
      required this.value,
      required this.onChanged,
      required this.items,
      this.defaultText});

  @override
  Widget build(BuildContext context) {
    return Container(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
          border: UIConstants.getDefaultBorder(context, null),
          borderRadius: BorderRadius.circular(8),
        ),
        child: DropdownButton<T>(
          value: value,
          hint: defaultText != null
              ? Text(
                  defaultText!,
                  style: context.text.bodyMedium
                      .copyWith(color: context.color.secondaryText),
                )
              : null,
          isExpanded: true,
          dropdownColor: context.color.background,
          underline: const SizedBox(),
          icon: Icon(Icons.keyboard_arrow_down_rounded,
              color: context.color.secondaryText),
          style: context.text.bodyMedium,
          items: items,
          onChanged: onChanged,
        ));
  }
}
