import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:injectable/injectable.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';
import 'package:neighbours/features/home/data/services/layer_service.dart';
import 'package:neighbours/features/plan_b/domain/enitities/plan_b_map/plan_b_map_entity.dart';

@injectable
class PlanBLayerService extends LayerService {
  PlanBLayerService();

  static const String planBSourceId = "plan-b-source";
  static const String planBClustersLayerId = "plan-b-clusters-layer";
  static const String planBClusterCountLayerId = "plan-b-cluster-count-layer";
  static const String planBUnclusteredLayerId =
      "plan-b-unclustered-points-layer";
  static const String planBCircleLayerId = "plan-b-circle-layer";
  static const String planBTextLayerId = "plan-b-text-layer";
  static const String planBHaloLayerId = "plan-b-halo-layer";

  /// Инициализирует слои для отображения объектов Plan B
  @override
  Future<void> initializeLayers(
    MapboxMap mapboxMap,
    BuildContext context,
  ) async {
    final style = mapboxMap.style;
    // Фиолетовый цвет для кругов Plan B
    final planBColor = const Color(0xFF9C27B0).toARGB32();
    // Фиолетовый цвет с прозрачностью для ореола
    final planBHaloColor =
        const Color(0xFF9C27B0).withValues(alpha: 0.4).toARGB32();
    // Белый цвет для буквы "Б"
    final textColor = Colors.white.toARGB32();
    // Белый цвет для обводки
    final strokeColor = Colors.white.toARGB32();

    // Создаем источник данных
    await addSource(
      style,
      sourceId: planBSourceId,
      cluster: true,
      clusterRadius: 40,
      layers: [
        planBClustersLayerId,
        planBClusterCountLayerId,
        planBUnclusteredLayerId,
        planBCircleLayerId,
        planBTextLayerId,
        planBHaloLayerId,
      ],
    );

    // Создаем слой кластеров
    await _addClusterLayer(style, planBColor, strokeColor);

    // Создаем слой счетчика кластеров
    await addCountLayer(
      style,
      sourceId: planBSourceId,
      layerId: planBClusterCountLayerId,
    );

    // Создаем слой отдельных точек (круг с буквой Б)
    await _addUnClusteredLayer(
        style, planBColor, textColor, strokeColor, planBHaloColor);
  }

  /// Обновляет данные объектов на карте
  Future<void> updateData(
    BuildContext context,
    MapboxMap? mapboxMap,
    List<PlanBMapEntity> items,
  ) async {
    if (mapboxMap == null) return;
    final style = mapboxMap.style;

    final geoJson = await compute(_buildGeoJson, items);
    final geoJsonString = jsonEncode(geoJson);

    try {
      await style.setStyleSourceProperty(
        planBSourceId,
        "data",
        geoJsonString,
      );
    } catch (e) {
      debugPrint('Error updating plan b data: $e');
      throw Exception('Failed to update plan b data: $e');
    }
  }

  /// Парсит PlanBMapEntity из Feature properties
  PlanBMapEntity? parsePlanBFromFeature(Map<String, dynamic> feature) {
    try {
      final properties = (feature['properties'] as Map).map(
        (k, v) => MapEntry(k.toString(), v),
      );

      return PlanBMapEntity(
        id: properties['id'] as int,
        name: properties['name'] as String,
        latitude: (properties['latitude'] as num).toDouble(),
        longitude: (properties['longitude'] as num).toDouble(),
        categoryName: properties['categoryName'] as String,
        icon: properties['icon'] as String?,
        shortDescription: properties['shortDescription'] as String?,
        status: properties['status'] as String,
      );
    } catch (e) {
      debugPrint('Error parsing plan b from feature: $e');
      return null;
    }
  }

  Future<void> _addClusterLayer(
    StyleManager style,
    int circleColor,
    int strokeColor,
  ) async {
    await style.addLayer(
      CircleLayer(
        id: planBClustersLayerId,
        sourceId: planBSourceId,
        filter: ["has", "point_count"],
        circleRadius: 28,
        circleColor: circleColor,
        circleStrokeColor: strokeColor,
        circleStrokeWidth: 2,
      ),
    );
  }

  Future<void> _addUnClusteredLayer(
    StyleManager style,
    int circleColor,
    int textColor,
    int strokeColor,
    int haloColor,
  ) async {
    // Слой ореола (добавляем первым, чтобы он был под кругом)
    await style.addLayer(
      CircleLayer(
        id: planBHaloLayerId,
        sourceId: planBSourceId,
        filter: [
          "all",
          [
            "!",
            ["has", "point_count"]
          ],
        ],
        circleRadiusExpression: [
          "interpolate",
          ["linear"],
          ["zoom"],
          14,
          45,
          16,
          50,
          22,
          55
        ],
        circleColor: haloColor,
        circlePitchAlignment: CirclePitchAlignment.VIEWPORT,
        circlePitchScale: CirclePitchScale.VIEWPORT,
      ),
    );

    // Слой круга
    await style.addLayer(
      CircleLayer(
        id: planBCircleLayerId,
        sourceId: planBSourceId,
        filter: [
          "all",
          [
            "!",
            ["has", "point_count"]
          ],
        ],
        circleRadius: 20,
        circleColor: circleColor,
        circleStrokeColor: strokeColor,
        circleStrokeWidth: 2,
        circlePitchAlignment: CirclePitchAlignment.VIEWPORT,
        circlePitchScale: CirclePitchScale.VIEWPORT,
      ),
    );

    // Слой текста "Б"
    await style.addLayer(
      SymbolLayer(
        id: planBTextLayerId,
        sourceId: planBSourceId,
        filter: [
          "all",
          [
            "!",
            ["has", "point_count"]
          ],
        ],
        textField: "Б",
        textSize: 16,
        textColor: textColor,
        textAllowOverlap: true,
        textIgnorePlacement: true,
        textAnchor: TextAnchor.CENTER,
        textPitchAlignment: TextPitchAlignment.VIEWPORT,
        textFont: ["Open Sans Semibold", "Arial Unicode MS Bold"],
      ),
    );
  }

  Map<String, dynamic> _buildGeoJson(List<PlanBMapEntity> items) {
    return {
      "type": "FeatureCollection",
      "features": items.map((item) => _createFeatureFromPlanB(item)).toList(),
    };
  }

  /// Создает Feature из PlanBMapEntity
  Map<String, dynamic> _createFeatureFromPlanB(PlanBMapEntity item) {
    final props = {
      "id": item.id,
      "name": item.name,
      "latitude": item.latitude,
      "longitude": item.longitude,
      "categoryName": item.categoryName,
      "icon": item.icon,
      "shortDescription": item.shortDescription,
      "status": item.status,
    };
    return {
      "type": "Feature",
      "geometry": {
        "type": "Point",
        "coordinates": [item.longitude, item.latitude],
      },
      "properties": props,
    };
  }

  /// Показывает все слои Plan B
  Future<void> showAllLayers(StyleManager style) async {
    await setLayersVisibility(
      style,
      [
        planBClustersLayerId,
        planBClusterCountLayerId,
        planBCircleLayerId,
        planBTextLayerId,
        planBHaloLayerId,
      ],
      true,
    );
  }

  /// Скрывает все слои Plan B
  Future<void> hideAllLayers(StyleManager style) async {
    await setLayersVisibility(
      style,
      [
        planBClustersLayerId,
        planBClusterCountLayerId,
        planBCircleLayerId,
        planBTextLayerId,
        planBHaloLayerId,
      ],
      false,
    );
  }
}
