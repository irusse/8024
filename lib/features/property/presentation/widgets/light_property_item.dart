import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:neighbours/core/components/custom_gap.dart';
import 'package:neighbours/core/components/shaped_cached_image.dart';
import 'package:neighbours/core/constants/default_constants.dart';
import 'package:neighbours/core/extensions/context_ext.dart';
import 'package:neighbours/core/router/app_routes.dart';
import 'package:neighbours/features/property/domain/entities/light_property/light_property_entity.dart';
import 'package:neighbours/features/property/presentation/cubits/properties/properties_cubit.dart';

class LightPropertyItem extends StatelessWidget {
  final LightPropertyEntity property;

  const LightPropertyItem({
    super.key,
    required this.property,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PropertiesCubit, PropertiesState>(
      builder: (context, state) {
        // Проверяем есть ли полная информация об объекте в PropertiesCubit
        final fullProperty = state.properties[property.id];
        
        return GestureDetector(
          onTap: () => context.push(AppRouteBuilder.propertyDetails(property.id)),
          child: Container(
            height: 56,
            color: Colors.transparent,
            child: Row(
              children: [
                ShapedCachedImage(
                  url: fullProperty?.photo ?? property.picture,
                  radius: 24,
                ),
                const HorizontalGap(16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        fullProperty?.name ?? property.name,
                        style: context.text.bodyLarge.copyWith(
                          fontWeight: FontWeight.w600,
                          color: (fullProperty?.verificationStatus ?? property.verificationStatus) == 
                                DefaultConstants.verified
                              ? context.color.primary
                              : context.color.secondaryText,
                        ),
                      ),
                      const VerticalGap(4),
                      Text(
                        DefaultConstants.verificationStatus[
                          fullProperty?.verificationStatus ?? property.verificationStatus
                        ] ?? 'Неизвестно',
                        style: context.text.labelLarge.copyWith(
                          color: context.color.secondaryText,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.arrow_forward_ios_rounded,
                  color: context.color.secondaryText,
                  size: 20,
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
