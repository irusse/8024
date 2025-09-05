import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:neighbours/core/components/custom_gap.dart';
import 'package:neighbours/core/components/primary_button.dart';
import 'package:neighbours/core/components/shaped_cached_image.dart';
import 'package:neighbours/core/constants/default_constants.dart';
import 'package:neighbours/core/extensions/context_ext.dart';
import 'package:neighbours/features/property/domain/entities/property/property_entity.dart';

import '../../../../core/router/app_routes.dart';
import '../../../property/presentation/widgets/label_value_text.dart';

class PropertyInfoDialog extends StatelessWidget {
  final PropertyEntity property;

  const PropertyInfoDialog({super.key, required this.property});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            ShapedCachedImage(
              radius: 30,
              url: property.photo,
              border: Border.all(
                  color: property.verificationStatusColor(context), width: 1.5),
            ),
            const HorizontalGap(16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  property.name,
                  style: context.text.bodyLarge
                      .copyWith(fontWeight: FontWeight.w500),
                ),
                Text(
                  DefaultConstants.propertyTypeOptions[property.category] ??
                      'Неизвестно',
                  style: context.text.bodyMedium
                      .copyWith(color: context.color.secondaryText),
                )
              ],
            )
          ],
        ),
        const VerticalGap(8),
        LabelValueText(
            label: 'Пользователь',
            value: property.createdBy,
            textStyle: context.text.bodyMedium),
        const VerticalGap(8),
        LabelValueText(
          label: 'Состояние',
          value: property.buildVerificationStatusText(),
          valueColor: property.verificationStatusColor(context),
          textStyle: context.text.bodyMedium,
        ),
        const VerticalGap(16),
        PrimaryButton(
            text: 'Подробнее',
            verticalPadding: 10,
            onPressed: () {
              context.pop();
              context.push(AppRouteBuilder.propertyDetails(property.id));
            })
      ],
    );
  }
}
