import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:injectable/injectable.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';
import 'package:neighbours/core/extensions/context_ext.dart';
import 'package:neighbours/features/home/data/services/layer_service.dart';

import '../../../../core/constants/assets.dart';
import '../../../../core/data/models/event/event_model.dart';
import '../../../../core/domain/entities/event/event_entity.dart';
import 'map_icon_service.dart';

@injectable
class EventLayerService extends LayerService {
  final MapIconService _mapIconService;
  static const String eventsSourceId = "events-source";
  static const String eventsClustersLayerId = "events-clusters-layer";
  static const String eventsIconsLayerId = "events-icons-layer";
  static const String eventsTitlesLayerId = "events-titles-layer";
  static const String eventsClusterCountLayerId = "events-cluster-count-layer";
  static const String eventsUnclusteredLayerId =
      "events-unclustered-points-layer";
  static const squareImage = "square_image";

  EventLayerService(this._mapIconService);

  // Минимальный зум при котором видны точки/кластеры
  static const double minZoom = 14;

  static const double targetDp = 40; // целевой размер иконки на экране

  double get _dpr =>
      WidgetsBinding.instance.platformDispatcher.views.first.devicePixelRatio;

  int get _iconPx => (targetDp * _dpr).round();

  @override
  Future<void> initializeLayers(
      MapboxMap mapboxMap, BuildContext context) async {
    final clusterColor = context.color.primary.toARGB32();
    final style = mapboxMap.style;
    await addSource(
      style,
      sourceId: eventsSourceId,
      layers: [
        eventsClustersLayerId,
        eventsIconsLayerId,
        eventsTitlesLayerId,
        eventsClusterCountLayerId,
        eventsUnclusteredLayerId
      ],
      cluster: true,
      clusterRadius: 35,
    );

    await _addSquareIconToStyle(style);
    await _addClusterLayer(style, clusterColor);
    if (!context.mounted) return;
    await _addEventsTitlesLayer(style, context);
    await addCountLayer(style,
        sourceId: eventsSourceId,
        layerId: eventsClusterCountLayerId,
        minZoom: minZoom);

    await _addLayer(style);
    if (!context.mounted) return;
    await _addIconsLayer(style, Colors.white.toARGB32());
  }

  /// Парсит EventModel из Feature properties
  EventModel? parseEventFromFeature(Map<String, dynamic> feature) {
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

  Future<void> _addEventsTitlesLayer(
      StyleManager style, BuildContext context) async {
    await style.addLayer(SymbolLayer(
      id: eventsTitlesLayerId,
      sourceId: eventsSourceId,
      minZoom: minZoom,
      filter: [
        "all",
        [
          "!",
          ["has", "point_count"]
        ], // Только НЕ кластеры
      ],
      textFieldExpression: ['get', 'short_title'],
      textOffsetExpression: [
        "interpolate",
        ["linear"],
        ["zoom"],
        16,
        [
          "literal",
          [0, 1.8]
        ],
        21,
        [
          "literal",
          [0, 3]
        ],
      ],
      textSize: context.text.labelLarge.fontSize,
      textMaxWidth: 10,

      // Ограничить в символах (ориентировочно)
      textAnchor: TextAnchor.TOP,
      // Текст будет под иконкой
      textColor: context.color.primaryText.toARGB32(),
      textAllowOverlap: true,
      textIgnorePlacement: true,
    ));
  }

  Future<void> _addSquareIconToStyle(StyleManager style) async {
    // Загрузить PNG из assets
    final ByteData imageData = await rootBundle.load(Assets.images.square);
    final Uint8List bytes = imageData.buffer.asUint8List();

    // Создать MbxImage из байтов
    final mbxImage = MbxImage(
      width: 64,
      height: 64,
      data: bytes,
    );

    // Добавить изображение в стиль
    await style.addStyleImage(
      squareImage,
      // imageId
      0.9,
      // scale
      mbxImage,
      // image
      true,
      // sdf — нужно true, чтобы менять цвет через icon-color
      [],
      // stretchX (не нужен для простого изображения)
      [],
      // stretchY
      null, // content (необязательный)
    );
  }

  Future<void> _addClusterLayer(StyleManager style, int clusterColor) async {
    await style.addLayer(
      SymbolLayer(
          id: eventsClustersLayerId,
          sourceId: eventsSourceId,
          minZoom: minZoom,
          filter: [
            "all",
            ["has", "point_count"], // Только кластеры
          ],
          iconImage: squareImage,
          iconSizeExpression: [
            "interpolate",
            ["linear"],
            ["zoom"],
            16,
            0.5,
            18,
            0.7,
            21,
            0.8,
          ],
          iconColor: clusterColor,
          iconAllowOverlap: true),
    );
  }

  Map<String, dynamic> _createFeatureFromEvent(EventModel event) {
    final categoryColorHex = event.category.color;
    final iconImageId = 'icon_${event.category.id}';

    final properties = {
      ...event.toJson(),
      "category_color": categoryColorHex,
      "category_icon": event.category.icon,
      "image": event.image,
      "category_icon_id": iconImageId,
      "square_image": squareImage,
      "short_title": event.title.length > 20
          ? "${event.title.substring(0, 17)}…"
          : event.title,
    };
    return {
      "type": "Feature",
      "geometry": {
        "type": "Point",
        "coordinates": [event.longitude, event.latitude],
      },
      "properties": properties,
    };
  }

  Future<void> _addLayer(StyleManager style) async {
    await style.addLayer(SymbolLayer(
      id: eventsUnclusteredLayerId,
      sourceId: eventsSourceId,
      minZoom: minZoom,
      iconImage: squareImage,
      filter: [
        "all",
        [
          "!",
          ["has", "point_count"]
        ], // Не кластер
      ],
      iconSizeExpression: [
        "interpolate",
        ["linear"],
        ["zoom"],
        16,
        0.5,
        18,
        0.7,
        21,
        0.8,
      ],
      // Масштаб при необходимости
      iconAllowOverlap: true,
      iconIgnorePlacement: true,
      iconColorExpression: [
        'case',
        ['has', 'category_color'],
        ['get', 'category_color'],
        '#FF5722'
      ],
    ));
  }

  Future<void> _addIconsLayer(StyleManager style, int iconColor) async {
    await style.addLayer(
      SymbolLayer(
          id: eventsIconsLayerId,
          sourceId: eventsSourceId,
          minZoom: minZoom,
          filter: [
            "all",
            ["has", "category_icon_id"],
          ],
          iconImageExpression: ["get", "category_icon_id"],
          iconColor: iconColor,
          iconSize: 0.7,
          iconAllowOverlap: true,
          iconIgnorePlacement: true,
          iconAnchor: IconAnchor.CENTER),
    );
  }

  Map<String, dynamic> _createGeoJsonFromEvents(
    List<EventEntity> events,
  ) {
    final features = <Map<String, dynamic>>[];

    for (final event in events) {
      final eventModel = EventModel.fromEntity(event);
      final feature = _createFeatureFromEvent(eventModel);
      features.add(feature);
    }

    return {
      "type": "FeatureCollection",
      "features": features,
    };
  }

  Future<void> updateData(
    MapboxMap? mapboxMap,
    List<EventEntity> events,
  ) async {
    if (mapboxMap == null) return;
    final style = mapboxMap.style;
    await _loadEventIcons(style, events);
    final geoJson = _createGeoJsonFromEvents(events);
    final geoJsonString = jsonEncode(geoJson);

    try {
      await style.setStyleSourceProperty(
        eventsSourceId,
        "data",
        geoJsonString,
      );
    } catch (e) {
      debugPrint('Error updating events data: $e');
      throw Exception('Failed to update events data: $e');
    }
  }

  /// Загружает иконки для уведомлений
  Future<void> _loadEventIcons(
    StyleManager style,
    List<EventEntity> events,
  ) async {
    // Собираем уникальные иконки
    final uniqueIcons = <int, String>{};
    for (final event in events) {
      if (event.category.icon.isNotEmpty) {
        uniqueIcons[event.category.id] = event.category.icon;
      }
    }

    // Загружаем каждую уникальную иконку
    for (final entry in uniqueIcons.entries) {
      final categoryId = entry.key;
      final iconUrl = entry.value;
      final iconImageId = 'icon_$categoryId';

      try {
        // Проверяем, не загружена ли уже иконка
        final imageExists = await style.hasStyleImage(iconImageId);
        if (imageExists) continue;

        // Загружаем SVG иконку
        final iconBytes = await _mapIconService.loadSvgIcon(iconUrl,
            size: _iconPx.toDouble());
        if (iconBytes != null) {
          // Создаем MbxImage для Mapbox
          final mbxImage = MbxImage(
            width: _iconPx,
            height: _iconPx,
            data: iconBytes,
          );

          // Добавляем иконку в стиль карты
          await style.addStyleImage(
            iconImageId,
            _dpr,
            // scale
            mbxImage,
            true,
            // sdf
            [],
            // stretchX
            [],
            // stretchY
            null, // content
          );
        }
      } catch (e) {
        debugPrint('Error loading icon for category $categoryId: $e');
      }
    }
  }
}
