import 'package:freezed_annotation/freezed_annotation.dart';
import '../../../domain/entities/vote_option/vote_option_entity.dart';

part 'vote_option_model.g.dart';

@JsonSerializable()
class VoteOptionModel {
  final int id;
  final String text;
  final int votesCount;
  final double percentage;
  final bool isVotedByCurrentUser;

  VoteOptionModel({
    required this.id,
    required this.text,
    required this.votesCount,
    required this.percentage,
    required this.isVotedByCurrentUser,
  });

  factory VoteOptionModel.fromJson(Map<String, dynamic> json) =>
      _$VoteOptionModelFromJson(json);

  Map<String, dynamic> toJson() => _$VoteOptionModelToJson(this);

  /// Преобразование в доменную сущность
  VoteOptionEntity toEntity() => VoteOptionEntity(
        id: id,
        text: text,
        votesCount: votesCount,
        percentage: percentage,
        isVotedByCurrentUser: isVotedByCurrentUser,
      );

  /// Создание модели из доменной сущности
  factory VoteOptionModel.fromEntity(VoteOptionEntity entity) =>
      VoteOptionModel(
        id: entity.id,
        text: entity.text,
        votesCount: entity.votesCount,
        percentage: entity.percentage,
        isVotedByCurrentUser: entity.isVotedByCurrentUser,
      );
}
