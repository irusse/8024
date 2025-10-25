import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:neighbours/core/mixins/has_name_mixin.dart';

part 'participant_entity.freezed.dart';

@freezed
abstract class ParticipantEntity with _$ParticipantEntity implements HasName {
  const factory ParticipantEntity({
    required int id,
    required String firstName,
    String? address,
    String? lastName,
    String? avatar,
  }) = _ParticipantEntity;

  const ParticipantEntity._(); // нужно для добавления методов в freezed класс
}
