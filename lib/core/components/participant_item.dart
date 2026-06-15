import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:neighbours/core/components/default_circle_avatar.dart';
import 'package:neighbours/core/extensions/context_ext.dart';
import 'package:neighbours/core/router/app_routes.dart';

import 'custom_gap.dart';

class ParticipantItem extends StatelessWidget {
  final int id;
  final String fullName;
  final String? avatar;

  const ParticipantItem({
    super.key,
    required this.id,
    required this.fullName,
    this.avatar,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => context.push(AppRouteBuilder.otherProfile(id)),
      child: SizedBox(
        height: 64,
        child: Row(
          children: [
            DefaultCircleAvatar(
              name: fullName,
              id: id,
              radius: 24,
              textStyle: context.text.bodyLarge,
              url: avatar,
            ),
            const HorizontalGap(8),
            Text(
              fullName,
              style: context.text.bodyMedium,
            ),
          ],
        ),
      ),
    );
  }
}
