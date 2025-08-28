import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:neighbours/core/constants/default_constants.dart';
import 'package:neighbours/core/data/models/event/event_category_model.dart';
import 'package:neighbours/core/data/models/event/participant_model.dart';
import 'package:neighbours/core/domain/entities/event/event_entity.dart';
import '../../../config/app_config.dart';
import '../../../utils/date_time_converter.dart';

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
  final String? image;
  final bool? hasVoting;
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
    this.image,
    this.hasVoting,
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
    return entity.map(
      notification: (notification) => EventModel(
        id: notification.id,
        title: notification.title,
        description: notification.description,
        image: notification.image,
        latitude: notification.latitude,
        longitude: notification.longitude,
        type: DefaultConstants.notification,
        hasVoting: null,
        votingQuestion: null,
        hasMoneyCollection: null,
        moneyAmount: null,
        createdAt: notification.createdAt,
        creator: ParticipantModel.fromEntity(notification.creator),
        category: EventCategoryModel.fromEntity(notification.category),
        participants: notification.participants
            .map((p) => ParticipantModel.fromEntity(p))
            .toList(),
      ),
      event: (event) => EventModel(
        id: event.id,
        title: event.title,
        description: event.description,
        image: event.image,
        latitude: event.latitude,
        longitude: event.longitude,
        type: DefaultConstants.event,
        hasVoting: event.hasVoting,
        votingQuestion: event.votingQuestion,
        hasMoneyCollection: event.hasMoneyCollection,
        moneyAmount: event.moneyAmount,
        createdAt: event.createdAt,
        creator: ParticipantModel.fromEntity(event.creator),
        category: EventCategoryModel.fromEntity(event.category),
        participants: event.participants
            .map((p) => ParticipantModel.fromEntity(p))
            .toList(),
        eventDateTime: event.eventDateTime,
      ),
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
    // Определяем тип события по полю type
    if (type == DefaultConstants.notification) {
      return EventEntity.notification(
        id: id,
        title: title,
        latitude: latitude,
        participants: participants.map((p) => p.toEntity()).toList(),
        longitude: longitude,
        createdAt: createdAt.toLocal(),
        creator: creator.toEntity(),
        category: category.toEntity(),
        description: description,
        image: image,
      );
    } else {
      return EventEntity.event(
        id: id,
        title: title,
        latitude: latitude,
        longitude: longitude,
        createdAt: createdAt.toLocal(),
        creator: creator.toEntity(),
        category: category.toEntity(),
        hasVoting: hasVoting ?? false,
        hasMoneyCollection: hasMoneyCollection ?? false,
        participants: participants.map((p) => p.toEntity()).toList(),
        description: description,
        image: image,
        votingQuestion: votingQuestion,
        moneyAmount: moneyAmount,
        eventDateTime: eventDateTime,
      );
    }
  }
}
