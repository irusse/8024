import 'package:flutter/material.dart';
import 'package:neighbours/core/extensions/context_ext.dart';
import 'package:neighbours/features/event/domain/entities/event/event_category_entity.dart';

import '../../../../core/components/custom_svg.dart';

class NotificationCategoryMarker extends StatelessWidget {
  final EventCategoryEntity eventCategoryEntity;

  const NotificationCategoryMarker(
      {super.key, required this.eventCategoryEntity});

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Center(
        child: Container(
          alignment: Alignment.center,
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            color: context.color.secondary,
            shape: BoxShape.circle,
            border: Border.all(
              color: eventCategoryEntity.color,
              width: 4,
            ),
          ),
          child: CustomSvg(
            asset: eventCategoryEntity.icon,
            color: context.color.primaryText,
            width: 24,
            height: 24,
            isNetwork: true,
          ),
        ),
      ),
    );
  }
}
