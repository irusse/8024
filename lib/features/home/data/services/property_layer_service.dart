import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:injectable/injectable.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';
import 'package:neighbours/core/constants/default_constants.dart';
import 'package:neighbours/core/extensions/color_ext.dart';
import 'package:neighbours/core/extensions/context_ext.dart';
import 'package:neighbours/core/themes/theme.dart';
import 'package:neighbours/features/home/data/services/layer_service.dart';
import 'package:neighbours/features/home/data/services/map_icon_service.dart';
import 'package:neighbours/features/property/data/models/property/property_model.dart';
import 'package:neighbours/features/property/domain/entities/property/property_entity.dart';

@injectable
class PropertyLayerService extends LayerService {
  final MapIconService _mapIconService;

  PropertyLayerService(this._mapIconService);

  static const String propertiesSourceId = "properties-source";
  static const String propertiesClustersLayerId = "properties-clusters-layer";
  static const String propertiesClusterCountLayerId =
      "properties-cluster-count-layer";
  static const String propertiesUnclusteredLayerId =
      "properties-unclustered-points-layer";
  static const String propertyUnclusteredHaloLayer =
      "properties-unclustered-halo-layer";

  /// Инициализирует слои для отображения объектов недвижимости
  @override
  Future<void> initializeLayers(
    MapboxMap mapboxMap,
    BuildContext context,
  ) async {
    final style = mapboxMap.style;
    final primaryColor = context.color.primary.toHex();

    // Создаем источник данных
    await addSource(style,
        sourceId: propertiesSourceId,
        cluster: true,
        clusterRadius: 40,
        layers: [
          propertiesClustersLayerId,
          propertiesClusterCountLayerId,
          propertiesUnclusteredLayerId,
          propertyUnclusteredHaloLayer
        ]);

    // Создаем слой кластеров
    await _addClusterLayer(style);

    // Создаем слой счетчика кластеров
    await addCountLayer(style,
        sourceId: propertiesSourceId, layerId: propertiesClusterCountLayerId);

    // Создаем слой отдельных точек (фото как иконки)
    await _addUnClusteredLayer(style, primaryColor);
  }

  /// Обновляет данные объектов на карте
  Future<void> updateData(
    BuildContext context,
    MapboxMap? mapboxMap,
    Map<int, PropertyEntity> properties,
  ) async {
    if (mapboxMap == null) return;
    final style = mapboxMap.style;
    // Загрузим/добавим изображения в стиль перед обновлением GeoJSON
    await _loadPropertyPhotos(context, style, properties);
    final geoJson = await compute(_buildGeoJson, properties);
    final geoJsonString = jsonEncode(geoJson);

    try {
      await style.setStyleSourceProperty(
        propertiesSourceId,
        "data",
        geoJsonString,
      );
    } catch (e) {
      debugPrint('Error updating properties data: $e');
      throw Exception('Failed to update properties data: $e');
    }
  }

  /// Парсит PropertyModel из Feature properties
  PropertyModel? parsePropertyFromFeature(Map<String, dynamic> feature) {
    try {
      final properties = (feature['properties'] as Map).map(
        (k, v) => MapEntry(k.toString(), v),
      );
      return PropertyModel.fromJson(properties, withFullPhotoPath: false);
    } catch (e) {
      debugPrint('Error parsing property from feature: $e');
      return null;
    }
  }

  Future<void> _addClusterLayer(StyleManager style) async {
    await style.addLayer(
      CircleLayer(
        id: propertiesClustersLayerId,
        sourceId: propertiesSourceId,
        filter: ["has", "point_count"],
        circleRadius: 28,
        circleColor: CommonModeColors.blue.toARGB32(),
      ),
    );
  }

  Future<void> _addUnClusteredLayer(
      StyleManager style, String primaryColor) async {
    await style.addLayer(
      SymbolLayer(
          id: propertiesUnclusteredLayerId,
          sourceId: propertiesSourceId,
          filter: [
            "all",
            [
              "!",
              ["has", "point_count"]
            ],
          ],
          iconImageExpression: ["get", "photo_image_id"],
          iconAllowOverlap: true,
          iconIgnorePlacement: true,
          iconAnchor: IconAnchor.CENTER,
          iconPitchAlignment: IconPitchAlignment.VIEWPORT,
          iconSizeExpression: [
            "interpolate",
            ["linear"],
            ["zoom"],
            16,
            0.8,
            18,
            1,
            20,
            1.2,
            22,
            1.3
          ]),
    );
    await style.addLayerAt(
      CircleLayer(
        id: propertyUnclusteredHaloLayer,
        sourceId: propertiesSourceId,
        // показываем только некластеры и только VERIFIED
        filter: [
          "all",
          [
            "!",
            ["has", "point_count"]
          ],
          [
            "==",
            ["get", "verificationStatus"],
            DefaultConstants.verified
          ],
        ],
        // Вариант 1: постоянный экранный радиус (ореол чуть больше аватарки)
        circleRadiusExpression: [
          "interpolate",
          ["linear"],
          ["zoom"],
          14,
          50,
          16,
          55,
          18,
          61,
          20,
          63,
          22,
          65
        ],
        circleColor: CommonModeColors.blue.withValues(alpha: 0.4).toARGB32(),
        circlePitchAlignment: CirclePitchAlignment.VIEWPORT,
        circlePitchScale: CirclePitchScale.VIEWPORT,
      ),
      LayerPosition(below: propertiesUnclusteredLayerId),
    );
  }

  Map<String, dynamic> _buildGeoJson(Map<int, PropertyEntity> properties) {
    return {
      "type": "FeatureCollection",
      "features": properties.values
          .map((p) => _createFeatureFromProperty(PropertyModel.fromEntity(p)))
          .toList(),
    };
  }

  /// Создает Feature из PropertyModel
  Map<String, dynamic> _createFeatureFromProperty(PropertyModel property) {
    final props = {
      ...property.toJson(),
      "photo_image_id": property.id.toString(),
    };
    return {
      "type": "Feature",
      "geometry": {
        "type": "Point",
        "coordinates": [property.longitude, property.latitude],
      },
      "properties": props,
    };
  }

  /// Загружает и добавляет в стиль круглые фото объектов с оранжевой обводкой
  Future<void> _loadPropertyPhotos(
    BuildContext context,
    StyleManager style,
    Map<int, PropertyEntity> properties,
  ) async {
    final dpr = MediaQuery.of(context).devicePixelRatio;
    const double targetDp = 56;
    final int pxSize = (targetDp * dpr).round();

    final futures = properties.values.map((property) async {
      if (property.photo.isEmpty) return;

      final imageId = property.id.toString();
      if (await style.hasStyleImage(imageId)) return;

      try {
        final bytes = await _mapIconService.loadNetworkAvatar(
          property.photo,
          size: pxSize.toDouble(),
          borderColor: property.verificationStatusColor(context),
          borderWidth: 2 * dpr,
        );
        if (bytes == null) return;

        final mbxImage = MbxImage(width: pxSize, height: pxSize, data: bytes);
        await style.addStyleImage(imageId, dpr, mbxImage, false, [], [], null);
      } catch (e, st) {
        debugPrint('Error loading photo for property $imageId: $e\n$st');
      }
    });

    await Future.wait(futures);
  }
}
