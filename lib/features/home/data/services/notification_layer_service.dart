import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:injectable/injectable.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';
import 'package:neighbours/core/extensions/context_ext.dart';
import 'package:neighbours/features/event/data/models/event/event_model.dart';
import 'package:neighbours/features/event/domain/entities/event/event_entity.dart';
import 'package:neighbours/features/home/data/services/layer_service.dart';
import 'map_icon_service.dart';

@injectable
class NotificationLayerService extends LayerService {
  final MapIconService _mapIconService;

  NotificationLayerService(this._mapIconService);

  static const String notificationsSourceId = "notifications-source";
  static const String notificationsClustersLayerId =
      "notifications-clusters-layer";
  static const String notificationsClusterCountLayerId =
      "notifications-cluster-count-layer";
  static const String notificationsUnclusteredLayerId =
      "notifications-unclustered-points-layer";
  static const String notificationsIconsLayerId = "notifications-icons-layer";

  // Минимальный зум при котором видны точки/кластеры
  static const double minZoom = 14;

  static const double targetDp = 20; // целевой размер иконки на экране

  double get _dpr =>
      WidgetsBinding.instance.platformDispatcher.views.first.devicePixelRatio;

  int get _iconPx => (targetDp * _dpr).round();

  @override
  Future<void> initializeLayers(
    MapboxMap mapboxMap,
    BuildContext context,
  ) async {
    final style = mapboxMap.style;
    final circleColor = context.color.background.toARGB32();
    final iconColor = context.color.primaryText.toARGB32();
    await addSource(
      style,
      sourceId: notificationsSourceId,
      layers: [
        notificationsClustersLayerId,
        notificationsClusterCountLayerId,
        notificationsUnclusteredLayerId,
        notificationsIconsLayerId
      ],
      cluster: true,
      clusterRadius: 35,
    );

    // Добавляем слой кластеров
    await _addClusterLayer(style, circleColor);

    // Добавляем слой счетчика кластеров
    await addCountLayer(style,
        sourceId: notificationsSourceId,
        layerId: notificationsClusterCountLayerId,
        minZoom: minZoom);

    // Добавляем слой некластеризованных точек
    await _addLayer(style, circleColor);

    // Добавляем слой иконок
    await _addIconsLayer(style, iconColor);
  }

  /// Обновляет данные уведомлений на карте
  Future<void> updateData(
    MapboxMap? mapboxMap,
    List<EventEntity> notifications,
  ) async {
    if (mapboxMap == null) return;
    final style = mapboxMap.style;

    // Загружаем иконки для уведомлений
    await _loadNotificationIcons(style, notifications);

    final geoJson = _createGeoJsonFromNotifications(notifications);
    final geoJsonString = jsonEncode(geoJson);

    try {
      await style.setStyleSourceProperty(
        notificationsSourceId,
        "data",
        geoJsonString,
      );
    } catch (e) {
      debugPrint('Error updating notifications data: $e');
      throw Exception('Failed to update notifications data: $e');
    }
  }

  /// Парсит EventModel из Feature properties
  EventModel? parseNotificationFromFeature(Map<String, dynamic> feature) {
    try {
      final properties = (feature['properties'] as Map).map(
        (k, v) => MapEntry(k.toString(), v),
      );
      return EventModel.fromJson(properties, withFullCategoryIconPath: false);
    } catch (e) {
      debugPrint(e.toString());
    }
    return null;
  }

  Future<void> _addIconsLayer(StyleManager style, int iconColor) async {
    await style.addLayer(
      SymbolLayer(
          id: notificationsIconsLayerId,
          sourceId: notificationsSourceId,
          minZoom: minZoom,
          filter: [
            "all",
            ["has", "category_icon_id"],
          ],
          iconImageExpression: ["get", "category_icon_id"],
          iconColor: iconColor,
          iconSize: 1,
          iconAllowOverlap: true,
          iconIgnorePlacement: true,
          iconAnchor: IconAnchor.CENTER),
    );
  }

  /// Добавляет слой кластеров уведомлений
  Future<void> _addClusterLayer(StyleManager style, int circleColor) async {
    await style.addLayer(
      CircleLayer(
        id: notificationsClustersLayerId,
        sourceId: notificationsSourceId,
        minZoom: minZoom,
        filter: [
          "all",
          ["has", "point_count"], // Только кластеры
        ],
        circleRadiusExpression: [
          "interpolate",
          ["linear"],
          ["zoom"],
          13,
          16,
          16,
          18,
          20,
          20,
        ],
        circleColor: circleColor,
        circleStrokeWidth: 1.5,
        circleStrokeColor: Colors.white.toARGB32(),
      ),
    );
  }

  Future<void> _loadNotificationIcons(
    StyleManager style,
    List<EventEntity> notifications,
  ) async {
    final unique = {
      for (final n in notifications)
        if (n.category.icon.isNotEmpty) n.category.id: n.category.icon,
    };

    await Future.wait(unique.entries.map((entry) async {
      final id = 'icon_${entry.key}';
      try {
        final imageExists = await style.hasStyleImage(id);
        if (imageExists) return;

        final bytes = await _mapIconService.loadSvgIcon(
          entry.value,
          size: _iconPx.toDouble(),
        );
        if (bytes == null) return;

        final img = MbxImage(width: _iconPx, height: _iconPx, data: bytes);
        style.addStyleImage(id, _dpr, img, true, [], [], null);
      } catch (e) {
        debugPrint('Icon load failed for ${entry.key}: $e');
      }
    }));
  }

  /// Создает GeoJSON из уведомлений
  Map<String, dynamic> _createGeoJsonFromNotifications(
    List<EventEntity> notifications,
  ) {
    return {
      "type": "FeatureCollection",
      "features": notifications
          .map((e) => _createFeatureFromNotification(EventModel.fromEntity(e)))
          .toList(),
    };
  }

  /// Создает Feature из EventModel (уведомления)
  Map<String, dynamic> _createFeatureFromNotification(EventModel notification) {
    // Конвертируем цвет категории в hex для MapBox
    final categoryColorHex = notification.category.color;

    // Создаем уникальный ID для иконки
    final iconImageId = 'icon_${notification.category.id}';

    final properties = {
      ...notification.toJson(),
      "category_color": categoryColorHex,
      "category_icon": notification.category.icon,
      "category_icon_id": iconImageId
    };

    return {
      "type": "Feature",
      "geometry": {
        "type": "Point",
        "coordinates": [notification.longitude, notification.latitude],
      },
      "properties": properties,
    };
  }

  Future<void> _addLayer(StyleManager style, int circleColor) async {
    await style.addLayer(
      CircleLayer(
        minZoom: minZoom.toDouble(),
        id: notificationsUnclusteredLayerId,
        sourceId: notificationsSourceId,
        filter: [
          "all",
          [
            "!",
            ["has", "point_count"]
          ], // Не кластер
        ],
        circleRadiusExpression: [
          "interpolate",
          ["linear"],
          ["zoom"],
          16,
          20,
          18,
          25,
          21,
          30,
        ],
        circleColor: circleColor,
        circleStrokeColorExpression: [
          "case",
          ["has", "category_color"],
          ["get", "category_color"],
          "#FF5722"
        ],
        circleStrokeWidth: 3,
      ),
    );
  }
}
