import 'dart:ui';

import 'package:freezed_annotation/freezed_annotation.dart';

part 'event_category_entity.freezed.dart';

@freezed
abstract class EventCategoryEntity with _$EventCategoryEntity {
  const factory EventCategoryEntity({
    required int id,
    required String name,
    required String icon,
    required Color color,
    required String type,
    required bool isActive,
  }) = _EventCategoryEntity;
}
