import 'package:freezed_annotation/freezed_annotation.dart';

part 'notification_entity.freezed.dart';

@freezed
abstract class NotificationEntity with _$NotificationEntity {
  const factory NotificationEntity({
    required int id,
    required String type,
    required String title,
    required String message,
    required Map<String, dynamic> payload,
    required bool isRead,
    required DateTime createdAt,
    required DateTime updatedAt,
  }) = _NotificationEntity;
}
