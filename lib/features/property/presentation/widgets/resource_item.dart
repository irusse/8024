import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:neighbours/core/components/shaped_cached_image.dart';

import 'package:neighbours/core/extensions/context_ext.dart';
import 'package:neighbours/core/router/app_routes.dart';
import 'package:neighbours/features/property/domain/entities/resource/resource_entity.dart';

class ResourceItem extends StatelessWidget {
  final bool isUserProperty;
  final ResourceEntity resourceEntity;

  const ResourceItem(
      {super.key, required this.resourceEntity, required this.isUserProperty});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: isUserProperty
          ? () => context.push(
              AppRouteBuilder.resourceForm(resourceEntity.propertyId),
              extra: resourceEntity)
          : () {},
      child: Container(
        decoration: BoxDecoration(
            color: context.color.secondary,
            borderRadius: BorderRadius.circular(8)),
        child: Column(
          children: [
            AspectRatio(
              aspectRatio: 1,
              child: _showResourcePhoto(context, resourceEntity.photo),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              child: Text(
                resourceEntity.name,
                style: context.text.bodyMedium.copyWith(
                  fontWeight: FontWeight.w500,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _showResourcePhoto(BuildContext context, String? photo) {
    return ShapedCachedImage(
      url: resourceEntity.photo,
      isSquare: true,
      radius: 8,
    );
  }
}
