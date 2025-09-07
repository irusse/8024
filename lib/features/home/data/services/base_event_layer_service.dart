import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';
import 'package:neighbours/features/home/data/services/layer_service.dart';
import '../../../../core/data/models/event/event_model.dart';
import '../../../../core/domain/entities/event/event_entity.dart';
import 'map_icon_service.dart';

abstract class BaseEventLayerService extends LayerService {
  final MapIconService mapIconService;

  BaseEventLayerService(this.mapIconService);

  double get _dpr =>
      WidgetsBinding.instance.platformDispatcher.views.first.devicePixelRatio;

  int getIconPx(double targetDp) => (targetDp * _dpr).round();

  /// Абстрактные методы, которые разные у Events/Notifications
  String get sourceId;

  Future<void> addCustomLayers(MapboxMap mapboxMap, BuildContext context);

  Map<String, dynamic> createFeatureFromModel(EventModel model);

  Future<void> loadIcons(StyleManager style, Map<int, EventEntity> events);

  /// Общий updateData
  Future<void> updateData(
    MapboxMap? mapboxMap,
    Map<int, EventEntity> events,
  ) async {
    if (mapboxMap == null) return;
    final style = mapboxMap.style;

    await loadIcons(style, events);

    final geoJson = {
      "type": "FeatureCollection",
      "features": events.values
          .map((e) => createFeatureFromModel(EventModel.fromEntity(e)))
          .toList(),
    };

    final geoJsonString = jsonEncode(geoJson);

    try {
      await style.setStyleSourceProperty(
        sourceId,
        "data",
        geoJsonString,
      );
    } catch (e) {
      debugPrint('Error updating events data: $e');
      throw Exception('Failed to update events data: $e');
    }
  }

  /// Общий парсинг
  EventModel? parseModelFromFeature(Map<String, dynamic> feature) {
    try {
      final properties = (feature['properties'] as Map).map(
        (k, v) => MapEntry(k.toString(), v),
      );
      return EventModel.fromJson(properties,
          withFullCategoryIconPath: false, withFullPhotoPath: false);
    } catch (e) {
      debugPrint(e.toString());
    }
    return null;
  }
}
