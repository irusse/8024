import 'package:flutter/material.dart';
import 'package:neighbours/core/extensions/context_ext.dart';
import 'package:neighbours/features/home/presentation/widgets/plan_b_info_dialog.dart';
import 'package:neighbours/features/plan_b/domain/enitities/plan_b_map/plan_b_map_entity.dart';

class PlanBClusterList extends StatelessWidget {
  final List<PlanBMapEntity> items;

  const PlanBClusterList({super.key, required this.items});

  @override
  Widget build(BuildContext context) {
    final screenWidth =  MediaQuery.of(context).size.width;
    return SizedBox(
      height: 216,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: items.length,
        padding: const EdgeInsets.symmetric(horizontal: 8),
        itemBuilder: (context, index) {
          final planB = items[index];
          return Container(
            margin: const EdgeInsets.only(right: 8),
            width: screenWidth - 24,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              color: context.color.background,
            ),
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: PlanBInfoDialog(
              inClusterList: true,
              planB: planB,
            ),
          );
        },
      ),
    );
  }
}
