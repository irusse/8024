import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:neighbours/core/domain/entities/profile_deletion/profile_deletion_entity.dart';
import 'package:neighbours/core/utils/date_time_converter.dart';

part 'profile_deletion_model.g.dart';

@JsonSerializable()
class ProfileDeletionModel {
  final String message;

  @NullableDateTimeConverter()
  final DateTime? deletionScheduledAt;

  ProfileDeletionModel({
    required this.message,
    this.deletionScheduledAt,
  });

  factory ProfileDeletionModel.fromJson(Map<String, dynamic> json) =>
      _$ProfileDeletionModelFromJson(json);

  Map<String, dynamic> toJson() => _$ProfileDeletionModelToJson(this);

  ProfileDeletionEntity toEntity() => ProfileDeletionEntity(
    message: message,
    deletionScheduledAt: deletionScheduledAt,
  );

  factory ProfileDeletionModel.fromEntity(ProfileDeletionEntity entity) =>
      ProfileDeletionModel(
        message: entity.message,
        deletionScheduledAt: entity.deletionScheduledAt,
      );
}
