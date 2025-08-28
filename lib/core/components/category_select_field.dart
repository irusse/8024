import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:neighbours/core/extensions/context_ext.dart';

import '../../features/home/presentation/widgets/select_field.dart';
import 'bottom_sheet_dialog.dart';
import 'custom_gap.dart';
import 'custom_label.dart';
import 'custom_radio_button.dart';

class CategorySelectField<T> extends StatelessWidget {
  final String label;
  final String? selectedValue;
  final List<T> items;
  final String Function(T item) itemLabel;
  final void Function(T selected) onChanged;
  final bool Function(T item, String? selectedValue)? isSelected;

  const CategorySelectField({
    super.key,
    required this.label,
    required this.selectedValue,
    required this.items,
    required this.itemLabel,
    required this.onChanged,
    this.isSelected,
  });

  @override
  Widget build(BuildContext context) {
    final selectedItem = selectedValue != null
        ? items.firstWhere(
            (e) =>
                isSelected?.call(e, selectedValue) ??
                itemLabel(e) == selectedValue,
            orElse: () => items.first,
          )
        : null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CustomLabel(text: label, isRequired: true),
        const VerticalGap(4),
        SelectField(
          label: label,
          value: selectedItem != null ? itemLabel(selectedItem) : '',
          icon: Icons.keyboard_arrow_down_rounded,
          onTap: () => _showCategoryBottomSheet(context),
        ),
      ],
    );
  }

  void _showCategoryBottomSheet(BuildContext context) {
    showBaseBottomSheet<T>(
      backgroundColor: context.color.secondary,
      context: context,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: context.text.bodyMedium),
          const VerticalGap(8),
          ...items.map((item) {
            final labelText = itemLabel(item);
            final active = isSelected?.call(item, selectedValue) ??
                (labelText == selectedValue);
            return CustomRadioButton(
              value: labelText,
              title: labelText,
              isActive: active,
              inActiveColor: context.color.tertiary,
              titleTextStyle: context.text.bodyLarge,
              onTap: (_) {
                onChanged(item);
                context.pop();
              },
            );
          }).toList(),
        ],
      ),
    );
  }
}
