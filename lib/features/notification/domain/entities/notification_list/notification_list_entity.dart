import 'package:freezed_annotation/freezed_annotation.dart';

import '../notification/notification_entity.dart';

part 'notification_list_entity.freezed.dart';

@freezed
abstract class NotificationListEntity with _$NotificationListEntity {
  const factory NotificationListEntity({
    required List<NotificationEntity> data,
    required int unreadCount,
  }) = _NotificationListEntity;
}
