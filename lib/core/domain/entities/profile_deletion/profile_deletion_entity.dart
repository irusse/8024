import 'package:freezed_annotation/freezed_annotation.dart';

part 'profile_deletion_entity.freezed.dart';

@freezed
class ProfileDeletionEntity with _$ProfileDeletionEntity {
  const factory ProfileDeletionEntity({
    required String message,
    DateTime? deletionScheduledAt,
  }) = _ProfileDeletionEntity;
}
