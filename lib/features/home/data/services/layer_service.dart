import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';

/*
* 🔹 clusterMaxZoom
Это максимальный zoom, до которого точки будут кластеризоваться.
Когда ты приближаешь карту дальше, чем clusterMaxZoom, кластеры разваливаются на отдельные точки.
🧠 Пример:

clusterMaxZoom: 14 — пока ты на зуме 14 или меньше, точки будут группироваться в "пузырьки".
При зуме 15 и выше — появляются отдельные точки, без кластеров.
👉 Чем меньше clusterMaxZoom, тем раньше кластеры разваливаются при приближении.


* */

/*
* 🔹 clusterRadius
Это радиус (в пикселях), в котором Mapbox ищет точки, чтобы сгруппировать в кластер.
Например:
clusterRadius: 50 — если две точки ближе, чем 50px на экране, они объединятся.
clusterRadius: 10 — кластеров будет больше, потому что расстояние меньше.
📏 Важно: радиус измеряется в пикселях экрана, не в метрах на земле!
* */

/// Класс, описывающий информацию о кластере точек на карте
class ClusterInfo {
  final dynamic id; // Уникальный идентификатор кластера
  final int pointCount; // Количество точек в кластере
  final double latitude; // Географическая широта центра кластера
  final double longitude; // Географическая долгота центра кластера

  ClusterInfo({
    required this.id,
    required this.pointCount,
    required this.latitude,
    required this.longitude,
  });
}

/// Абстрактный сервис для работы со слоями карты Mapbox
abstract class LayerService {
  /// Метод инициализации слоёв карты (реализуется в наследниках)
  Future<void> initializeLayers(MapboxMap mapboxMap, BuildContext context);

  /// Добавляет новый источник данных (GeoJSON) на карту
  ///
  /// [sourceId] — идентификатор источника
  /// [cluster] — включить ли кластеризацию
  /// [clusterRadius] — радиус кластеризации в px
  /// [clusterMaxZoom] — до какого уровня zoom работают кластеры
  Future<void> addSource(
    StyleManager style, {
    required List<String> layers,
    required String sourceId,
    required bool cluster,
    double? clusterRadius,
    double? clusterMaxZoom,
  }) async {
    try {
      // Проверяем, существует ли источник
      final sourceExists = await style.styleSourceExists(sourceId);
      if (sourceExists) {
        await style.removeStyleSource(sourceId);
        await _removeExistingLayers(style, layers);
      }

      // Добавляем новый GeoJSON источник
      await style.addSource(
        GeoJsonSource(
          id: sourceId,
          data: jsonEncode({"type": "FeatureCollection", "features": []}),
          // Пустой набор данных
          cluster: cluster,
          clusterMaxZoom: clusterMaxZoom,
          clusterRadius: clusterRadius,
        ),
      );
    } catch (e) {
      debugPrint('Error adding source $sourceId: $e');
      throw Exception('Failed to add $sourceId source: $e');
    }
  }

  Future<void> _removeExistingLayers(
      StyleManager style, List<String> layers) async {
    for (final layerId in layers) {
      final exists = await style.styleLayerExists(layerId);
      if (!exists) continue;

      try {
        await style.removeStyleLayer(layerId);
        debugPrint("Удаляю слой $layerId");
      } catch (e) {
        // Если параллельно стиль сменился или слой уже удалён — пропускаем
        debugPrint('Skip removing layer $layerId: $e');
      }
    }
  }

  /// Добавляет слой с текстовым счетчиком кластеров
  ///
  /// Показывает количество точек внутри кластера.
  Future<void> addCountLayer(
    StyleManager style, {
    required String sourceId,
    required String layerId,
    double? minZoom,
    double? maxZoom,
    List<Object>? filter,
  }) async {
    await style.addLayer(
      SymbolLayer(
        id: layerId,
        minZoom: minZoom,
        maxZoom: maxZoom,
        sourceId: sourceId,
        filter: [
          "all",
          ["has", "point_count"], // Показываем только кластеры
          ...?filter
        ],
        textFieldExpression: ["get", "point_count_abbreviated"],
        // Кол-во точек
        textSize: 16,
        textAllowOverlap: true,
        textColor: Colors.white.toARGB32(),
        textFont: ["Open Sans Semibold", "Arial Unicode MS Bold"],
      ),
    );
  }

  /// Парсит информацию о кластере из GeoJSON feature
  ///
  /// Возвращает [ClusterInfo] с координатами и количеством точек
  ClusterInfo? parseClusterFromFeature(
    Map<String, dynamic> feature, {
    required String featureKey,
  }) {
    try {
      // Получаем свойства кластера
      final properties = (feature[featureKey] as Map).map(
        (k, v) => MapEntry(k.toString(), v),
      );

      // Получаем геометрию (координаты)
      final geometry = (feature['geometry'] as Map).map(
        (k, v) => MapEntry(k.toString(), v),
      );

      final clusterId = properties['cluster_id'];
      final pointCount = properties['point_count'];
      final coordinates = geometry['coordinates'];

      return ClusterInfo(
        id: clusterId,
        pointCount: pointCount,
        latitude: coordinates[1] as double,
        longitude: coordinates[0] as double,
      );
    } catch (e) {
      debugPrint('Error parsing cluster from feature: $e');
      return null;
    }
  }

  /// Получает все элементы (листья) кластера
  ///
  /// [limit] — ограничение на количество элементов
  /// [offset] — смещение для пагинации
  Future<List<Map<String, Object>>> getClusterLeaves({
    required MapboxMap mapboxMap,
    required String sourceId,
    required Map<String?, Object?> clusterFeature,
    int? limit,
    int offset = 0,
  }) async {
    try {
      // Запрашиваем элементы кластера через API Mapbox
      final result = await mapboxMap.getGeoJsonClusterLeaves(
        sourceId,
        clusterFeature,
        limit,
        offset,
      );

      final features = result.featureCollection;
      if (features == null || features.isEmpty) return [];

      // Очищаем от null и приводим к Map<String, Object>
      final cleanedFeatures = features.map((feature) {
        if (feature == null) return <String, Object>{};

        return {
          for (var entry in feature.entries)
            if (entry.key != null && entry.value != null)
              entry.key!: entry.value!
        };
      }).toList();

      return cleanedFeatures;
    } catch (e) {
      debugPrint('Error fetching notification cluster leaves: $e');
      return [];
    }
  }

  /// Показывает слой на карте (устанавливает visibility в "visible")
  Future<void> showLayer(StyleManager style, String layerId) async {
    try {
      final exists = await style.styleLayerExists(layerId);
      if (!exists) return;
      
      await style.setStyleLayerProperty(
        layerId,
        "visibility",
        "visible",
      );
    } catch (e) {
      debugPrint('Error showing layer $layerId: $e');
    }
  }

  /// Скрывает слой на карте (устанавливает visibility в "none")
  Future<void> hideLayer(StyleManager style, String layerId) async {
    try {
      final exists = await style.styleLayerExists(layerId);
      if (!exists) return;
      
      await style.setStyleLayerProperty(
        layerId,
        "visibility",
        "none",
      );
    } catch (e) {
      debugPrint('Error hiding layer $layerId: $e');
    }
  }

  /// Переключает видимость нескольких слоёв одновременно
  Future<void> setLayersVisibility(
    StyleManager style,
    List<String> layerIds,
    bool visible,
  ) async {
    final visibility = visible ? "visible" : "none";
    
    for (final layerId in layerIds) {
      try {
        final exists = await style.styleLayerExists(layerId);
        if (!exists) continue;
        
        await style.setStyleLayerProperty(
          layerId,
          "visibility",
          visibility,
        );
      } catch (e) {
        debugPrint('Error setting visibility for layer $layerId: $e');
      }
    }
  }
}
