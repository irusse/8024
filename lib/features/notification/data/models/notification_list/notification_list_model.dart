import 'package:freezed_annotation/freezed_annotation.dart';

import '../notification/notification_model.dart';

part 'notification_list_model.g.dart';

@JsonSerializable()
class NotificationListModel {
  final List<NotificationModel> data;
  final int unreadCount;

  NotificationListModel({
    required this.data,
    required this.unreadCount,
  });

  factory NotificationListModel.fromJson(Map<String, dynamic> json) =>
      _$NotificationListModelFromJson(json);

  Map<String, dynamic> toJson() => _$NotificationListModelToJson(this);
}
