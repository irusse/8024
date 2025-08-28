import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:neighbours/core/components/default_loading_overlay.dart';
import 'package:neighbours/core/components/participant_item.dart';
import 'package:neighbours/features/community/presentation/widgets/error_with_try_btn.dart';

import '../cubits/community/community_cubit.dart';

class UsersTab extends StatelessWidget {
  final int communityId;

  const UsersTab({
    super.key,
    required this.communityId,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CommunityCubit, CommunityState>(
      builder: (context, state) {
        if (state.isParticipantsLoading && state.participants.isEmpty) {
          return const DefaultLoadingOverlay(
            transparent: true,
          );
        }

        if (state.participantsError != null && state.participants.isEmpty) {
          return ErrorWithTryBtn(
              error: state.participantsError!,
              onErrorClick: () => context
                  .read<CommunityCubit>()
                  .fetchCommunityParticipants(communityId));
        }

        return RefreshIndicator(
          onRefresh: () => context
              .read<CommunityCubit>()
              .fetchCommunityParticipants(communityId),
          child: ListView.builder(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(16),
            itemCount: state.participants.length,
            itemBuilder: (context, index) {
              final user = state.participants[index];

              return ParticipantItem(
                id: user.id,
                fullName: user.fullName,
                avatar: user.avatar,
              );
            },
          ),
        );
      },
    );
  }
}
