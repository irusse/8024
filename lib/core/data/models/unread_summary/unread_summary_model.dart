import 'package:freezed_annotation/freezed_annotation.dart';
import '../../../domain/entities/unread_summary/unread_summary_entity.dart';
import '../../../utils/int_key_converter.dart';

part 'unread_summary_model.g.dart';

@JsonSerializable()
class UnreadSummaryModel {
  @IntKeyMapConverter()
  final Map<int, int> count;

  @JsonKey(name: 'EVENT')
  final int event;

  @JsonKey(name: 'NOTIFICATION')
  final int notification;

  UnreadSummaryModel({
    required this.count,
    required this.event,
    required this.notification,
  });

  factory UnreadSummaryModel.fromJson(Map<String, dynamic> json) =>
      _$UnreadSummaryModelFromJson(json);

  Map<String, dynamic> toJson() => _$UnreadSummaryModelToJson(this);

  UnreadSummaryEntity toEntity() => UnreadSummaryEntity(
        count: count,
        event: event,
        notification: notification,
      );

  factory UnreadSummaryModel.fromEntity(UnreadSummaryEntity entity) =>
      UnreadSummaryModel(
        count: entity.count,
        event: entity.event,
        notification: entity.notification,
      );
}
