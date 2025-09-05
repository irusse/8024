import 'package:flutter/material.dart';
import 'package:neighbours/core/components/custom_gap.dart';
import 'package:neighbours/features/home/presentation/widgets/property_item.dart';
import 'package:neighbours/features/property/domain/entities/property/property_entity.dart';

class GenericListView<T> extends StatelessWidget {
  final List<T> items;

  const GenericListView({super.key, required this.items});

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 1 / 2,
      child: ListView.separated(
          itemBuilder: (context, index) => _item(index),
          separatorBuilder: (context, index) => const VerticalGap(16),
          itemCount: items.length),
    );
  }

  Widget _item(int index) {
    if (items[index] is PropertyEntity) {
      return PropertyItem(entity: items[index] as PropertyEntity);
    }
    return const SizedBox.shrink();
  }
}
