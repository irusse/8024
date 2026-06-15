import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:neighbours/core/utils/int_key_converter.dart';
import 'package:neighbours/features/chat/domain/entities/event_unread_summary/event_unread_summary_entity.dart';

part 'event_unread_summary_model.g.dart';

@JsonSerializable()
class EventUnreadSummaryModel {
  @IntKeyMapConverter()
  final Map<int, int> count;

  @JsonKey(name: 'EVENT')
  final int event;

  @JsonKey(name: 'NOTIFICATION')
  final int notification;

  EventUnreadSummaryModel({
    required this.count,
    required this.event,
    required this.notification,
  });

  factory EventUnreadSummaryModel.fromJson(Map<String, dynamic> json) =>
      _$EventUnreadSummaryModelFromJson(json);

  Map<String, dynamic> toJson() => _$EventUnreadSummaryModelToJson(this);

  EventUnreadSummaryEntity toEntity() => EventUnreadSummaryEntity(
        count: count,
        event: event,
        notification: notification,
      );

  factory EventUnreadSummaryModel.fromEntity(EventUnreadSummaryEntity entity) =>
      EventUnreadSummaryModel(
        count: entity.count,
        event: entity.event,
        notification: entity.notification,
      );
}
