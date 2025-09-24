import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:neighbours/core/extensions/context_ext.dart';
import 'package:neighbours/core/router/app_routes.dart';
import 'package:neighbours/features/community/domain/entities/light_community/light_community_entity.dart';

class LightCommunityItem extends StatelessWidget {
  final LightCommunityEntity community;

  const LightCommunityItem({super.key, required this.community});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => context.push(AppRouteBuilder.community(community.id)),
      child: Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: context.color.secondary,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              Icon(
                Icons.group,
                size: 20,
                color: context.color.primary,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  community.name,
                  style: context.text.bodyMedium.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
