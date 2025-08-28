import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:neighbours/features/event/data/models/vote_option/vote_option_model.dart';

import '../../../domain/entities/voting_results/voting_results_entity.dart';

part 'voting_results_model.g.dart';

@JsonSerializable()
class VotingResultsModel {
  final int eventId;
  final String votingQuestion;
  final int totalVotes;
  final List<VoteOptionModel> options;
  final bool hasVoted;

  VotingResultsModel({
    required this.eventId,
    required this.votingQuestion,
    required this.totalVotes,
    required this.options,
    required this.hasVoted,
  });

  factory VotingResultsModel.fromJson(Map<String, dynamic> json) {
    final model = _$VotingResultsModelFromJson(json);
    return model;
  }

  Map<String, dynamic> toJson() => _$VotingResultsModelToJson(this);

  VotingResultsEntity toEntity() => VotingResultsEntity(
        eventId: eventId,
        votingQuestion: votingQuestion,
        totalVotes: totalVotes,
        options: options.map((o) => o.toEntity()).toList(),
        hasVoted: hasVoted,
      );

  factory VotingResultsModel.fromEntity(VotingResultsEntity entity) =>
      VotingResultsModel(
        eventId: entity.eventId,
        votingQuestion: entity.votingQuestion,
        totalVotes: entity.totalVotes,
        options:
            entity.options.map((o) => VoteOptionModel.fromEntity(o)).toList(),
        hasVoted: entity.hasVoted,
      );
}
