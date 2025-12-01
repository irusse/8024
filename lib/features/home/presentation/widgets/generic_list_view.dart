import 'package:flutter/material.dart';
import 'package:neighbours/core/components/custom_gap.dart';
import 'package:neighbours/features/home/presentation/widgets/property_item.dart';
import 'package:neighbours/features/property/domain/entities/property/property_entity.dart';
import 'package:neighbours/features/plan_b/domain/enitities/plan_b_map/plan_b_map_entity.dart';
import 'package:neighbours/features/home/presentation/widgets/plan_b_info_dialog.dart';
import 'package:neighbours/core/extensions/context_ext.dart';

class GenericListView<T> extends StatelessWidget {
  final List<T> items;

  const GenericListView({super.key, required this.items});

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 1 / 2,
      child: ListView.separated(
          itemBuilder: (context, index) => _item(context, index),
          separatorBuilder: (context, index) => const VerticalGap(16),
          itemCount: items.length),
    );
  }

  Widget _item(BuildContext context, int index) {
    if (items[index] is PropertyEntity) {
      return PropertyItem(entity: items[index] as PropertyEntity);
    } else if (items[index] is PlanBMapEntity) {
      return Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: context.color.secondary,
        ),
        child: PlanBInfoDialog(
          inClusterList: true,
          planB: items[index] as PlanBMapEntity,
        ),
      );
    }
    return const SizedBox.shrink();
  }
}

