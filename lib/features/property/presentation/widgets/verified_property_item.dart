import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:neighbours/core/components/custom_gap.dart';
import 'package:neighbours/core/components/shaped_cached_image.dart';
import 'package:neighbours/core/constants/default_constants.dart';
import 'package:neighbours/core/extensions/context_ext.dart';
import 'package:neighbours/core/themes/theme.dart';
import 'package:neighbours/features/property/domain/entities/user_verified_property/user_verified_property_entity.dart';

import '../../../../core/router/app_routes.dart';

class VerifiedPropertyItem extends StatelessWidget {
  final UserVerifiedPropertyEntity entity;

  const VerifiedPropertyItem({super.key, required this.entity});

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('yy.MM.dd HH:mm');
    final property = entity.property;
    return GestureDetector(
      onTap: () => context.push(AppRouteBuilder.propertyDetails(property.id)),
      child: Container(
        height: 56,
        color: Colors.transparent,
        child: Row(
          children: [
            ShapedCachedImage(
              url: property.photo,
              radius: 24,
            ),
            const HorizontalGap(16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  property.name,
                  style: context.text.bodyLarge.copyWith(
                    fontWeight: FontWeight.w600,
                    color:
                        property.verificationStatus == DefaultConstants.verified
                            ? context.color.primary
                            : CommonModeColors.orange,
                  ),
                ),
                const VerticalGap(4),
                Text(
                  dateFormat.format(entity.verifiedAt),
                  style: context.text.labelLarge
                      .copyWith(color: context.color.secondaryText),
                )
              ],
            ),
            const Spacer(),
            Icon(
              Icons.arrow_forward_ios_rounded,
              color: context.color.secondaryText,
              size: 20,
            )
          ],
        ),
      ),
    );
  }
}
