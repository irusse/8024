import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

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
              aspectRatio: 1.65,
              child: _showResourcePhoto(context, resourceEntity.photo),
            ),
            Center(
              child: Padding(
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
            ),
          ],
        ),
      ),
    );
  }

  Widget _showResourcePhoto(BuildContext context, String? photo) {
    if (resourceEntity.photo != null) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: CachedNetworkImage(
          imageUrl: resourceEntity.photo!,
          fit: BoxFit.cover,
          progressIndicatorBuilder: (context, url, downloadProgress) =>
              SizedBox(
            width: 32,
            height: 32,
            child: CircularProgressIndicator(
              value: downloadProgress.progress,
              color: context.color.primary,
              strokeWidth: 1,
            ),
          ),
        ),
      );
    }
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        color: context.color.tertiary,
      ),
      child: Icon(
        Icons.camera_alt_outlined,
        color: context.color.primaryText,
      ),
    );
  }
}
