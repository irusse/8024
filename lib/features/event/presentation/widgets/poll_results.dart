import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:neighbours/core/components/custom_gap.dart';
import 'package:neighbours/core/components/default_loading_overlay.dart';
import 'package:neighbours/core/constants/ui_constants.dart';
import 'package:neighbours/core/extensions/context_ext.dart';
import 'package:neighbours/core/state/api_state.dart';
import 'package:neighbours/core/components/error_with_try_btn.dart';
import 'package:neighbours/features/event/domain/entities/vote_option/vote_option_entity.dart';
import 'package:neighbours/features/event/presentation/cubits/vote/vote_cubit.dart';

class PollResults extends StatefulWidget {
  final int eventId;
  final bool canVote;
  final bool isCompleted;

  const PollResults(
      {super.key,
      required this.eventId,
      required this.canVote,
      required this.isCompleted});

  @override
  State<PollResults> createState() => _PollResultsState();
}

class _PollResultsState extends State<PollResults> {
  @override
  void initState() {
    super.initState();
    _getVotingResults();
  }

  void _getVotingResults() {
    context.read<VoteCubit>().getVotingResults(eventId: widget.eventId);
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<VoteCubit, VoteState>(
      listener: (context, state) {},
      builder: (context, state) {
        if (state.votingResultsState.isLoading) {
          return const DefaultLoadingOverlay(
            transparent: true,
          );
        }
        if (state.votingResultsState.isFailure) {
          return ErrorWithTryBtn(
              error: state.votingResultsState.error!,
              onErrorClick: () => _getVotingResults());
        }

        final votingResults = state.votingResults?.options;

        if (votingResults != null && votingResults.isEmpty) {
          return const Center(
            child: Text('Нет результатов голосования'),
          );
        }

        return Stack(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(
                  horizontal: UIConstants.defaultHorizontalPadding),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    state.votingResults!.votingQuestion,
                    style: context.text.titleSmall
                        .copyWith(fontWeight: FontWeight.w500),
                  ),
                  const VerticalGap(16),
                  ...votingResults!.map((result) => Padding(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: _pollOptionItem(
                            result, state.votingResults!.totalVotes),
                      )),
                  const VerticalGap(24),
                ],
              ),
            ),
            if (widget.isCompleted)
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    color: context.color.background.withValues(alpha: 0.7),
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
          ],
        );
      },
    );
  }

  Widget _pollOptionItem(VoteOptionEntity entity, int totalVotes) {
    final progress =
        entity.votesCount > 0 ? entity.votesCount / totalVotes : 0.0;
    return GestureDetector(
      onTap: () {
        // Если мероприятие завершено, не реагируем на нажатия
        if (widget.isCompleted) {
          return;
        }
        if (!widget.canVote) {
          context.snackbar.info(context,
              "Для того чтобы проголосовать нужно сначала встпуить в мероприятие");
          return;
        }
        if (entity.isVotedByCurrentUser) {
          context.read<VoteCubit>().cancelVote(eventId: widget.eventId);
        } else {
          context
              .read<VoteCubit>()
              .vote(eventId: widget.eventId, optionId: entity.id);
        }
      },
      child: Container(
        color: Colors.transparent,
        child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  _pollCircle(context, entity.isVotedByCurrentUser),
                  const HorizontalGap(8),
                  Expanded(
                      child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          entity.text,
                          style: context.text.bodyMedium,
                        ),
                      ),
                      const HorizontalGap(8),
                      Text(entity.votesCount.toString(),
                          style: context.text.labelLarge)
                    ],
                  ))
                ],
              ),
              const VerticalGap(4),
              Container(
                margin: const EdgeInsets.only(left: 32),
                child: LinearProgressIndicator(
                  color: context.color.primary,
                  backgroundColor:
                      context.color.tertiary.withValues(alpha: 0.2),
                  value: progress,
                  minHeight: 8,
                  borderRadius: BorderRadius.circular(30),
                ),
              )
            ]),
      ),
    );
  }

  Widget _pollCircle(BuildContext context, bool isActive) {
    return AnimatedContainer(
      width: 24,
      height: 24,
      decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(
              width: 2,
              color:
                  isActive ? context.color.primary : context.color.secondary)),
      padding: const EdgeInsets.all(4),
      duration: UIConstants.defaultAnimationDuration,
      child: AnimatedContainer(
        duration: UIConstants.defaultAnimationDuration,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: isActive ? context.color.primary : null,
        ),
      ),
    );
  }
}
