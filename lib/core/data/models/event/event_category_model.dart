import 'dart:ui';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:neighbours/core/config/app_config.dart';
import 'package:neighbours/core/domain/entities/event/event_category_entity.dart';
import 'package:neighbours/core/extensions/color_ext.dart';

part 'event_category_model.g.dart';

@JsonSerializable()
class EventCategoryModel {
  final int id;
  final String name;
  final String icon;
  final String color;
  final String type;
  final bool isActive;

  const EventCategoryModel({
    required this.id,
    required this.name,
    required this.icon,
    required this.color,
    required this.type,
    required this.isActive,
  });

  factory EventCategoryModel.fromJson(Map<String, dynamic> json,
      {bool withFullIconPath = true}) {
    final model = _$EventCategoryModelFromJson(json);
    final icon = model.icon;
    return EventCategoryModel(
      id: model.id,
      name: model.name,
      color: model.color,
      type: model.type,
      isActive: model.isActive,
      icon: (withFullIconPath && icon.isNotEmpty)
          ? '${AppConfig.baseUrl}/files/$icon'
          : icon,
    );
  }

  factory EventCategoryModel.fromEntity(EventCategoryEntity entity) =>
      EventCategoryModel(
        id: entity.id,
        name: entity.name,
        icon: entity.icon,
        color: entity.color.toHex(),
        type: entity.type,
        isActive: entity.isActive,
      );

  Map<String, dynamic> toJson() => _$EventCategoryModelToJson(this);

  EventCategoryEntity toEntity() => EventCategoryEntity(
        id: id,
        name: name,
        icon: icon,
        color: _hexToColor(color),
        type: type,
        isActive: isActive,
      );

  Color _hexToColor(String hex) {
    final buffer = StringBuffer();
    if (hex.length == 7 && hex.startsWith('#')) {
      buffer.write('ff'); // default opacity
      buffer.write(hex.substring(1));
    } else if (hex.length == 9 && hex.startsWith('#')) {
      buffer.write(hex.substring(1));
    } else {
      throw FormatException("Invalid color format: $hex");
    }
    return Color(int.parse(buffer.toString(), radix: 16));
  }
}
