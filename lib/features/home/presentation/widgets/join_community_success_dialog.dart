import 'package:flutter/material.dart';
import 'package:neighbours/core/components/custom_gap.dart';
import 'package:neighbours/core/components/primary_button.dart';
import 'package:neighbours/core/domain/entities/community/community_entity.dart';
import 'package:neighbours/core/extensions/context_ext.dart';

class JoinCommunitySuccessDialog extends StatelessWidget {
  final CommunityEntity communityEntity;

  const JoinCommunitySuccessDialog({super.key, required this.communityEntity});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(communityEntity.name,
            style: context.text.bodyLarge.copyWith(
                fontWeight: FontWeight.w500, overflow: TextOverflow.ellipsis)),
        const VerticalGap(4),
        Text('ID: ${communityEntity.id}',
            style: context.text.bodySmall
                .copyWith(color: context.color.secondaryText)),
        const VerticalGap(8),
        PrimaryButton(text: 'Перейти в сообщесвто', onPressed: () {})
      ],
    );
  }
}
