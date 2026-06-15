import 'package:collection/collection.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:neighbours/core/constants/default_constants.dart';
import 'package:neighbours/core/domain/entities/participant/participant_entity.dart';

import 'event_category_entity.dart';

part 'event_entity.freezed.dart';

@freezed
abstract class EventEntity with _$EventEntity {
  const factory EventEntity({
    required int id,
    required String title,
    required double latitude,
    required double longitude,
    required DateTime createdAt,
    required ParticipantEntity creator,
    required EventCategoryEntity category,
    required List<ParticipantEntity> participants,
    required String description,
    required String type,
    required bool hasVoting,
    required String status,
    String? image,
    bool? hasMoneyCollection,
    String? votingQuestion,
    double? moneyAmount,
    DateTime? eventDateTime,
  }) = _EventEntity;
}

extension EventEntityX on EventEntity {
  bool isParticipant(int userId) =>
      participants.firstWhereOrNull((p) => p.id == userId) != null;

  bool isCreator(int userId) => creator.id == userId;

  /// Удобные проверки по type
  bool get isNotification => type == DefaultConstants.notification;

  bool get isFullEvent => type == DefaultConstants.event;

  bool get isCompleted => status == DefaultConstants.completed;
}
