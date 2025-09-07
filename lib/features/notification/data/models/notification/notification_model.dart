import 'dart:convert';

import 'package:freezed_annotation/freezed_annotation.dart';

import '../../../domain/entities/notification/notification_entity.dart';

part 'notification_model.g.dart';

@JsonSerializable()
class NotificationModel {
  final int id;
  final String type;
  final String title;
  final String message;
  final Map<String, dynamic> payload;
  final bool isRead;
  final DateTime createdAt;
  final DateTime updatedAt;

  NotificationModel({
    required this.id,
    required this.type,
    required this.title,
    required this.message,
    required this.payload,
    required this.isRead,
    required this.createdAt,
    required this.updatedAt,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) =>
      _$NotificationModelFromJson(json);

  Map<String, dynamic> toJson() => _$NotificationModelToJson(this);

  /// Преобразование модели в Entity
  NotificationEntity toEntity() => NotificationEntity(
        id: id,
        type: type,
        title: title,
        message: message,
        payload: payload,
        isRead: isRead,
        createdAt: createdAt.toLocal(),
        updatedAt: updatedAt,
      );

  /// Создание модели из Entity
  factory NotificationModel.fromEntity(NotificationEntity entity) =>
      NotificationModel(
        id: entity.id,
        type: entity.type,
        title: entity.title,
        message: entity.message,
        payload: entity.payload,
        isRead: entity.isRead,
        createdAt: entity.createdAt,
        updatedAt: entity.updatedAt,
      );
}
