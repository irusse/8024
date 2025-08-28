import 'package:collection/collection.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:neighbours/core/domain/entities/event/event_category_entity.dart';
import 'participant_entity.dart';

part 'event_entity.freezed.dart';

@freezed
class EventEntity with _$EventEntity {
  const factory EventEntity.notification({
    required int id,
    required String title,
    required double latitude,
    required double longitude,
    required DateTime createdAt,
    required ParticipantEntity creator,
    required EventCategoryEntity category,
    required List<ParticipantEntity> participants,
    required String description,
    String? image,
  }) = NotificationEvent;

  // Event variant - для полноценных событий с голосованием/сбором денег
  const factory EventEntity.event({
    required int id,
    required String title,
    required double latitude,
    required double longitude,
    required DateTime createdAt,
    required ParticipantEntity creator,
    required EventCategoryEntity category,
    required bool hasVoting,
    required bool hasMoneyCollection,
    required List<ParticipantEntity> participants,
    required String description,
    String? image,
    String? votingQuestion,
    double? moneyAmount,
    DateTime? eventDateTime,
  }) = FullEvent;
}

extension EventEntityX on EventEntity {
  bool isParticipant(int userId) =>
      participants.firstWhereOrNull((p) => p.id == userId) != null;

  bool isCreator(int userId) => creator.id == userId;
}
