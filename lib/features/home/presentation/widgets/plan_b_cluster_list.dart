import 'package:flutter/material.dart';
import 'package:neighbours/core/components/custom_gap.dart';
import 'package:neighbours/core/components/drag_handle.dart';
import 'package:neighbours/core/constants/ui_constants.dart';
import 'package:neighbours/core/extensions/context_ext.dart';
import 'package:neighbours/features/home/presentation/widgets/plan_b_info_dialog.dart';
import 'package:neighbours/features/plan_b/domain/enitities/plan_b_map/plan_b_map_entity.dart';

class PlanBClusterList extends StatelessWidget {
  final List<PlanBMapEntity> items;

  const PlanBClusterList({super.key, required this.items});

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;

    return Container(
      height: screenHeight * 0.9,
      decoration: BoxDecoration(
        color: context.color.background,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
      ),
      child: Column(
        children: [
          const VerticalGap(24),
          DragHandle(),
          const VerticalGap(24),
          Expanded(
            child: ListView.separated(
              padding: EdgeInsets.symmetric(
                  horizontal: UIConstants.defaultHorizontalPadding),
              itemCount: items.length,
              separatorBuilder: (context, index) => Divider(
                color: context.color.secondary,
                height: 48,
                thickness: 2,
              ),
              itemBuilder: (context, index) {
                final planB = items[index];
                return Column(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        color: context.color.secondary,
                      ),
                      child: PlanBInfoDialog(
                        inClusterList: true,
                        planB: planB,
                      ),
                    ),
                    if (index == items.length - 1) const VerticalGap(16),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
