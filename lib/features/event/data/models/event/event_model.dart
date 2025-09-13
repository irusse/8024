import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:neighbours/core/config/app_config.dart';
import 'package:neighbours/core/utils/date_time_converter.dart';
import 'package:neighbours/core/data/models/participant/participant_model.dart';
import 'package:neighbours/features/event/domain/entities/event/event_entity.dart';

import 'event_category_model.dart';

part 'event_model.g.dart';

@JsonSerializable()
class EventModel {
  final int id;
  final String title;
  @JsonKey(defaultValue: '')
  final String description;
  final double latitude;
  final double longitude;
  final String type;
  @DateTimeConverter()
  final DateTime createdAt;
  final ParticipantModel creator;
  final EventCategoryModel category;
  final List<ParticipantModel> participants;
  final bool hasVoting;
  final String? image;
  final String? votingQuestion;
  final bool? hasMoneyCollection;
  final double? moneyAmount;
  @NullableDateTimeConverter()
  final DateTime? eventDateTime;

  const EventModel({
    required this.id,
    required this.title,
    required this.description,
    required this.latitude,
    required this.longitude,
    required this.type,
    required this.createdAt,
    required this.creator,
    required this.category,
    required this.participants,
    required this.hasVoting,
    this.image,
    this.votingQuestion,
    this.hasMoneyCollection,
    this.moneyAmount,
    this.eventDateTime,
  });

  factory EventModel.fromJson(
    Map<String, dynamic> json, {
    bool withFullPhotoPath = true,
    bool withFullCategoryIconPath = true,
  }) {
    final model = _$EventModelFromJson(json);
    final image = model.image;
    final categoryJson = json['category'] as Map<String, dynamic>;

    return EventModel(
      id: model.id,
      title: model.title,
      description: model.description,
      image: (withFullPhotoPath && image != null && image.isNotEmpty)
          ? '${AppConfig.baseUrl}/files/$image'
          : image,
      latitude: model.latitude,
      longitude: model.longitude,
      type: model.type,
      hasVoting: model.hasVoting,
      votingQuestion: model.votingQuestion,
      hasMoneyCollection: model.hasMoneyCollection,
      moneyAmount: model.moneyAmount,
      createdAt: model.createdAt,
      creator: model.creator,
      category: EventCategoryModel.fromJson(categoryJson,
          withFullIconPath: withFullCategoryIconPath),
      participants: model.participants,
      eventDateTime: model.eventDateTime,
    );
  }

  factory EventModel.fromEntity(EventEntity entity) {
    return EventModel(
      id: entity.id,
      title: entity.title,
      description: entity.description,
      latitude: entity.latitude,
      longitude: entity.longitude,
      type: entity.type,
      createdAt: entity.createdAt,
      creator: ParticipantModel.fromEntity(entity.creator),
      category: EventCategoryModel.fromEntity(entity.category),
      participants: entity.participants
          .map((p) => ParticipantModel.fromEntity(p))
          .toList(),
      image: entity.image,
      hasVoting: entity.hasVoting,
      votingQuestion: entity.votingQuestion,
      hasMoneyCollection: entity.hasMoneyCollection,
      moneyAmount: entity.moneyAmount,
      eventDateTime: entity.eventDateTime,
    );
  }

  static List<EventModel> fromJsonList(Map<String, dynamic> json) {
    final events = json['events'] as List<dynamic>?;
    if (events == null) return [];
    return events
        .map((e) => EventModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Map<String, dynamic> toJson() => _$EventModelToJson(this);

  EventEntity toEntity() {
    return EventEntity(
      id: id,
      title: title,
      latitude: latitude,
      longitude: longitude,
      createdAt: createdAt.toLocal(),
      creator: creator.toEntity(),
      category: category.toEntity(),
      participants: participants.map((p) => p.toEntity()).toList(),
      description: description,
      type: type,
      image: image,
      hasVoting: hasVoting,
      hasMoneyCollection: hasMoneyCollection,
      votingQuestion: votingQuestion,
      moneyAmount: moneyAmount,
      eventDateTime: eventDateTime,
    );
  }
}
