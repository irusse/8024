import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:neighbours/core/components/custom_gap.dart';
import 'package:neighbours/core/components/shaped_cached_image.dart';
import 'package:neighbours/core/constants/default_constants.dart';
import 'package:neighbours/core/domain/entities/property/property_entity.dart';
import 'package:neighbours/core/extensions/context_ext.dart';
import 'package:neighbours/core/router/app_routes.dart';

class PropertyItem extends StatelessWidget {
  final PropertyEntity entity;

  const PropertyItem({super.key, required this.entity});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => context.push(AppRouteBuilder.propertyDetails(entity.id)),
      child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          height: 100,
          decoration: BoxDecoration(
              color: context.color.secondary,
              borderRadius: BorderRadius.circular(16)),
          child: Row(
            children: [
              Expanded(
                  child: Row(
                children: [
                  ShapedCachedImage(
                    radius: 32,
                    url: entity.photo,
                    border: Border.all(
                        width: 2,
                        color: entity.verificationStatusColor(context)),
                  ),
                  const HorizontalGap(16),
                  Expanded(
                      child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        entity.name,
                        style: context.text.bodyLarge
                            .copyWith(fontWeight: FontWeight.w600),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const VerticalGap(4),
                      Text(
                        DefaultConstants.propertyTypeOptions[entity.category] ??
                            'Неизвестно',
                        style: context.text.bodyMedium
                            .copyWith(color: context.color.secondaryText),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ))
                ],
              )),
              Icon(
                Icons.arrow_forward_ios_rounded,
                color: context.color.secondaryText,
                size: 16,
              )
            ],
          )),
    );
  }
}
