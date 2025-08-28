import 'package:freezed_annotation/freezed_annotation.dart';

part 'vote_option_entity.freezed.dart';

@freezed
class VoteOptionEntity with _$VoteOptionEntity {
  const factory VoteOptionEntity({
    required int id,
    required String text,
    required int votesCount,
    required double percentage,
    required bool isVotedByCurrentUser,
  }) = _VoteOptionEntity;
}
