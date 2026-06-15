import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:neighbours/core/domain/entities/participant/participant_entity.dart';

part 'seen_user_entity.freezed.dart';

@freezed
abstract class SeenUserEntity with _$SeenUserEntity {
  const factory SeenUserEntity({
    required DateTime seenAt,
    required ParticipantEntity user,
  }) = _SeenUserEntity;
}
