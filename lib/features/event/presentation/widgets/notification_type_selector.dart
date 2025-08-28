import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:neighbours/core/components/custom_gap.dart';
import 'package:neighbours/core/components/custom_svg.dart';
import 'package:neighbours/core/constants/default_constants.dart';
import 'package:neighbours/core/cubits/events/events_cubit.dart';
import 'package:neighbours/core/extensions/context_ext.dart';

class NotificationTypeSelector extends StatefulWidget {
  final int? selectedType;
  final ValueChanged<int> onSelected;

  const NotificationTypeSelector({
    super.key,
    required this.selectedType,
    required this.onSelected,
  });

  @override
  State<NotificationTypeSelector> createState() =>
      _NotificationTypeSelectorState();
}

class _NotificationTypeSelectorState extends State<NotificationTypeSelector> {
  @override
  Widget build(BuildContext context) {
    final categories = context
        .read<EventsCubit>()
        .state
        .categories
        .where((c) => c.type == DefaultConstants.notification);
    final selected =
        context.read<EventsCubit>().getEventCategoryById(widget.selectedType);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: categories.map((type) {
            final isSelected = type.id == widget.selectedType;
            return GestureDetector(
              onTap: () => widget.onSelected(type.id),
              child: CustomSvg(
                asset: type.icon,
                isNetwork: true,
                color: isSelected
                    ? context.color.primary
                    : context.color.primaryText,
                width: 24,
                height: 24,
              ),
            );
          }).toList(),
        ),
        const VerticalGap(16),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
          decoration: BoxDecoration(
            color: context.color.secondary,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            selected != null ? selected.name : 'Выберите',
            style: context.text.bodyLarge.copyWith(
                fontWeight: FontWeight.w500, color: context.color.primary),
            textAlign: TextAlign.center,
          ),
        ),
      ],
    );
  }
}
