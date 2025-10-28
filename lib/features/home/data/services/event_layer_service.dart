import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:injectable/injectable.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';
import 'package:neighbours/core/extensions/context_ext.dart';
import 'package:neighbours/core/themes/theme.dart';
import 'package:neighbours/features/event/data/models/event/event_model.dart';
import 'package:neighbours/features/event/domain/entities/event/event_entity.dart';
import 'package:neighbours/features/home/data/services/layer_service.dart';

import '../../../../core/constants/assets.dart';
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

  static const double targetIconDp = 24; // целевой размер иконки на экране
  static const double targetImageDp = 80; // целевой размер иконки на экране

  double get _dpr =>
      WidgetsBinding.instance.platformDispatcher.views.first.devicePixelRatio;

  int get _iconPx => (targetIconDp * _dpr).round();

  int get _imagePx => (targetImageDp * _dpr).round();

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
      clusterRadius: 20,
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
          [0, 2]
        ],
        21,
        [
          "literal",
          [0, 3.2]
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
    final hasEventImage = event.image != null && event.image!.isNotEmpty;
    final eventImageId = hasEventImage ? 'event_image_${event.id}' : null;

    final properties = {
      ...event.toJson(),
      "category_color": categoryColorHex,
      "category_icon": event.category.icon,
      "image": event.image,
      "category_icon_id": iconImageId,
      "event_image_id": eventImageId,
      "has_event_image": hasEventImage,
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
      // Условное отображение: если есть изображение события - показываем его, иначе - квадратный фон
      iconImageExpression: [
        'case',
        [
          '==',
          ['get', 'has_event_image'],
          true
        ],
        ['get', 'event_image_id'],
        squareImage
      ],
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
        0.6,
        18,
        0.7,
      ],
      iconAllowOverlap: true,
      iconIgnorePlacement: true,
      // Цвет применяется только для квадратного фона (когда нет изображения события)
      iconColorExpression: [
        'case',
        [
          '==',
          ['get', 'has_event_image'],
          true
        ],
        'rgba(255, 255, 255, 0)', // прозрачный для изображений
        [
          'case',
          ['has', 'category_color'],
          ['get', 'category_color'],
          '#FF5722'
        ]
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
            // Показываем иконку только если нет изображения события
            [
              "!=",
              ["get", "has_event_image"],
              true
            ],
          ],
          iconImageExpression: ["get", "category_icon_id"],
          iconColor: iconColor,
          iconSize: 1,
          iconAllowOverlap: true,
          iconIgnorePlacement: true,
          iconAnchor: IconAnchor.CENTER),
    );
  }

  Map<String, dynamic> _createGeoJsonFromEvents(List<EventEntity> events) => {
        "type": "FeatureCollection",
        "features": events
            .map((e) => _createFeatureFromEvent(EventModel.fromEntity(e)))
            .toList(),
      };

  Future<void> updateData(
    MapboxMap? mapboxMap,
    List<EventEntity> events,
  ) async {
    if (mapboxMap == null) return;
    final style = mapboxMap.style;
    final filteredEvents = events.where((event) => !event.isCompleted).toList();
    await _loadEventIcons(style, filteredEvents);
    final geoJson = _createGeoJsonFromEvents(filteredEvents);
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

  /// Загружает иконки и изображения для событий
  Future<void> _loadEventIcons(
    StyleManager style,
    List<EventEntity> events,
  ) async {
    final uniqueIcons = <int, String>{
      for (final e in events)
        if (e.category.icon.isNotEmpty) e.category.id: e.category.icon,
    };

    // Иконки категорий
    final iconFutures = uniqueIcons.entries.map((entry) async {
      final id = 'icon_${entry.key}';
      if (await style.hasStyleImage(id)) return;

      final bytes = await _mapIconService.loadSvgIcon(
        entry.value,
        size: _iconPx.toDouble(),
      );
      if (bytes == null) return;

      final img = MbxImage(width: _iconPx, height: _iconPx, data: bytes);
      await style.addStyleImage(id, _dpr, img, true, [], [], null);
    });

    // Картинки событий
    final imageFutures = events
        .where((e) => e.image?.isNotEmpty == true)
        .map((e) => _loadEventImages(style, e));

    await Future.wait([...iconFutures, ...imageFutures]);
  }

  Future<void> _loadEventImages(StyleManager style, EventEntity event) async {
    if (event.image != null && event.image!.isNotEmpty) {
      final eventImageId = 'event_image_${event.id}';

      try {
        // Проверяем, не загружено ли уже изображение
        final imageExists = await style.hasStyleImage(eventImageId);
        if (imageExists) return;

        // Загружаем изображение события с зеленой обводкой
        final imageBytes = await _mapIconService.loadNetworkAvatar(event.image!,
            size: _imagePx.toDouble(),
            shape: AvatarShape.rounded,
            borderColor: CommonModeColors.green,
            borderWidth: 5 * _dpr,
            borderRadius: 2 * _dpr);

        if (imageBytes != null) {
          // Создаем MbxImage для Mapbox
          final mbxImage = MbxImage(
            width: _imagePx,
            height: _imagePx,
            data: imageBytes,
          );

          // Добавляем изображение в стиль карты
          await style.addStyleImage(
            eventImageId,
            _dpr,
            // scale
            mbxImage,
            false,
            // sdf = false для растровых изображений
            [],
            // stretchX
            [],
            // stretchY
            null, // content
          );
        }
      } catch (e) {
        debugPrint('Error loading image for event ${event.id}: $e');
      }
    }
  }
}
