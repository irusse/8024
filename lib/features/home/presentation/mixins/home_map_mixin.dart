import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart' hide Error;
import 'package:neighbours/core/components/bottom_sheet_dialog.dart';
import 'package:neighbours/core/cubits/user/user_cubit.dart';
import 'package:neighbours/core/cubits/user_location/user_location_cubit.dart';
import 'package:neighbours/core/di/injection.dart';
import 'package:neighbours/core/utils/map_camera_utils.dart';
import 'package:neighbours/features/event/domain/entities/event/event_entity.dart';
import 'package:neighbours/features/event/presentation/cubits/events/events_cubit.dart'
    show EventsCubit;
import 'package:neighbours/features/home/data/services/event_layer_service.dart';
import 'package:neighbours/features/home/data/services/notification_layer_service.dart';
import 'package:neighbours/features/home/data/services/property_layer_service.dart';
import 'package:neighbours/features/home/data/services/plan_b_layer_service.dart';
import 'package:neighbours/features/home/domain/enums/map_display_mode.dart';
import 'package:neighbours/features/home/presentation/pages/home.dart';
import 'package:neighbours/features/home/presentation/widgets/event_cluster_list.dart';
import 'package:neighbours/features/home/presentation/widgets/event_info_dialog.dart';
import 'package:neighbours/features/home/presentation/widgets/property_info_dialog.dart';
import 'package:neighbours/features/home/presentation/widgets/notification_info_dialog.dart';
import 'package:neighbours/features/home/presentation/widgets/plan_b_info_dialog.dart';
import 'package:neighbours/features/home/presentation/widgets/plan_b_cluster_list.dart';
import 'package:neighbours/features/plan_b/domain/enitities/plan_b_map/plan_b_map_entity.dart';
import 'package:neighbours/features/plan_b/presentation/cubits/plan_b/plan_b_cubit.dart';
import 'package:neighbours/features/property/presentation/cubits/properties/properties_cubit.dart';

import '../widgets/notification_cluster_list.dart';

mixin HomeMapMixin<T extends StatefulWidget> on State<Home> {
  MapboxMap? get mapboxMapController;

  set mapboxMapController(MapboxMap? controller);

  PropertyLayerService get propertyLayerService;

  PlanBLayerService get planBLayerService;

  EventLayerService get eventLayerService;

  NotificationLayerService get notificationLayerService;

  // Camera preparation state
  final ValueNotifier<bool> _isMapReadyNotifier = ValueNotifier<bool>(false);
  CameraOptions? _initialCameraOptions;

  /// Getter для состояния готовности карты
  ValueNotifier<bool> get isMapReadyNotifier => _isMapReadyNotifier;

  /// Getter для начальных опций камеры
  CameraOptions? get initialCameraOptions => _initialCameraOptions;

  void onMapCreated(MapboxMap mapboxMap) async {
    mapboxMapController = mapboxMap;
  }

  /// Подготовка начальной камеры
  Future<void> prepareInitialCamera() async {
    // Сначала пытаемся загрузить кешированную позицию
    final cachedPosition =
        await context.read<UserLocationCubit>().fetchLocalLocation();

    if (cachedPosition != null) {
      _initialCameraOptions = MapCameraUtils.createCameraOptions(
        lat: cachedPosition.latitude,
        lng: cachedPosition.longitude,
      );
    } else {
      // Если кешированной позиции нет, используем дефолтную
      _initialCameraOptions = MapCameraUtils.defaultCameraOptions();
    }

    if (mounted) {
      _isMapReadyNotifier.value = true;
    }
  }

  /// Dispose resources
  void disposeMapResources() {
    _isMapReadyNotifier.dispose();
  }

  /// Публичный метод для пересоздания слоев
  Future<void> reinitializeLayersAfterThemeChange() async {
    if (mapboxMapController == null) return;

    try {
      // Пересоздаем все слои
      await _initializeLayers();
      if (!mounted) return;

      // Обновляем данные на карте
      final propertiesState = context.read<PropertiesCubit>().state;
      final events = context.read<EventsCubit>().allFullEvents();
      final notifications = context.read<EventsCubit>().allNotifications();

      if (propertiesState.properties.isNotEmpty) {
        propertyLayerService.updateData(
            context, mapboxMapController, propertiesState.properties);
      }

      if (events.isNotEmpty) {
        await eventLayerService.updateData(
          mapboxMapController,
          events,
        );
      }
      if (events.isNotEmpty) {
        await notificationLayerService.updateData(
          mapboxMapController,
          notifications,
        );
      }

      final planBState = context.read<PlanBCubit>().state;
      if (planBState.items.isNotEmpty) {
        await planBLayerService.updateData(
          context,
          mapboxMapController,
          planBState.items,
        );
      }
    } catch (e) {
      debugPrint('Error reinitializing layers after theme change: $e');
    }
  }

  Future<void> _initializeLayers() async {
    await notificationLayerService.initializeLayers(
      mapboxMapController!,
      context,
    );
    if (!mounted) return;
    await eventLayerService.initializeLayers(
      mapboxMapController!,
      context,
    );
    if (!mounted) return;
    await propertyLayerService.initializeLayers(
      mapboxMapController!,
      context,
    );
    if (!mounted) return;
    await planBLayerService.initializeLayers(
      mapboxMapController!,
      context,
    );
  }

  Future<void> _onClusterClick(ScreenCoordinate screenPoint) async {
    // Сначала проверяем, попали ли мы в кластер
    final clusterFeatures = await mapboxMapController?.queryRenderedFeatures(
      RenderedQueryGeometry.fromScreenCoordinate(screenPoint),
      RenderedQueryOptions(layerIds: [
        PropertyLayerService.propertiesClustersLayerId,
        NotificationLayerService.notificationsClustersLayerId,
        EventLayerService.eventsClustersLayerId,
        PlanBLayerService.planBClustersLayerId,
      ]),
    );

    if (clusterFeatures != null && clusterFeatures.isNotEmpty) {
      // Нажали на кластер
      final feature = clusterFeatures.first?.queriedFeature.feature;
      final layer = clusterFeatures.first?.layers.first;

      if (feature == null) return;
      if (layer == PropertyLayerService.propertiesClustersLayerId) {
        final clusterInfo = propertyLayerService.parseClusterFromFeature(
            feature.cast<String, dynamic>(),
            featureKey: "properties");
        if (clusterInfo == null) return;
        await MapCameraUtils.zoomToCluster(
            mapboxMapController!, clusterInfo.latitude, clusterInfo.longitude);
        return;
      } else if (layer ==
          NotificationLayerService.notificationsClustersLayerId) {
        final leaves = await notificationLayerService.getClusterLeaves(
          mapboxMap: mapboxMapController!,
          sourceId: NotificationLayerService.notificationsSourceId,
          clusterFeature: feature.cast<String, Object?>(),
        );
        final List<EventEntity> notifications = [];
        for (final l in leaves) {
          final notification =
              notificationLayerService.parseNotificationFromFeature(
                  jsonDecode(jsonEncode(l)) as Map<String, dynamic>);
          if (notification != null) {
            notifications.add(notification.toEntity());
          }
        }
        if (!mounted) return;
        showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          backgroundColor: Colors.transparent,
          useSafeArea: true,
          // false т.к. у нас фиксированная высота
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
          ),
          builder: (_) {
            return BlocProvider.value(
              value: getIt<EventsCubit>(),
              child: NotificationClusterList(
                  notifications: notifications,
                  userId: context.read<UserCubit>().state.user.id,
                  onNotRelevantClick: (int value) {
                    context
                        .read<EventsCubit>()
                        .deleteEvent(eventId: value.toString());
                    context.pop();
                  }),
            );
          },
        );
      } else if (layer == EventLayerService.eventsClustersLayerId) {
        final leaves = await eventLayerService.getClusterLeaves(
          mapboxMap: mapboxMapController!,
          sourceId: EventLayerService.eventsSourceId,
          clusterFeature: feature.cast<String, Object?>(),
        );
        final List<EventEntity> events = [];
        for (final l in leaves) {
          final event = eventLayerService.parseEventFromFeature(
              jsonDecode(jsonEncode(l)) as Map<String, dynamic>);
          if (event != null) {
            events.add(event.toEntity());
          }
        }
        if (!mounted) return;
        showModalBottomSheet(
          context: context,
          isScrollControlled: false,
          backgroundColor: Colors.transparent,
          // false т.к. у нас фиксированная высота
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
          ),
          builder: (_) {
            return EventClusterList(
              events: events,
            );
          },
        );
      } else if (layer == PlanBLayerService.planBClustersLayerId) {
        final leaves = await planBLayerService.getClusterLeaves(
          mapboxMap: mapboxMapController!,
          sourceId: PlanBLayerService.planBSourceId,
          clusterFeature: feature.cast<String, Object?>(),
        );
        final List<PlanBMapEntity> planBItems = [];
        for (final l in leaves) {
          final planB = planBLayerService.parsePlanBFromFeature(
              jsonDecode(jsonEncode(l)) as Map<String, dynamic>);
          if (planB != null) {
            planBItems.add(planB);
          }
        }
        if (!mounted) return;
        showModalBottomSheet(
          context: context,
          isScrollControlled: false,
          backgroundColor: Colors.transparent,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
          ),
          builder: (_) {
            return PlanBClusterList(
              items: planBItems,
            );
          },
        );
      }
    }
  }

  Future<void> _onPointClick(ScreenCoordinate screenPoint) async {
    // Если не попали в кластер, проверяем отдельные точки
    final pointFeatures = await mapboxMapController?.queryRenderedFeatures(
      RenderedQueryGeometry.fromScreenCoordinate(screenPoint),
      RenderedQueryOptions(layerIds: [
        PropertyLayerService.propertiesUnclusteredLayerId,
      ]),
    );

    if (pointFeatures != null && pointFeatures.isNotEmpty) {
      // Нажали на отдельную точку свойства
      final feature = pointFeatures.first?.queriedFeature.feature;
      if (feature == null) return;

      final property = propertyLayerService
          .parsePropertyFromFeature(feature.cast<String, dynamic>());
      if (property == null) return;

      if (mounted) {
        showBaseBottomSheet(
            context: context,
            child: PropertyInfoDialog(property: property.toEntity()));
      }

      return;
    }

    // Проверяем отдельные уведомления
    final notificationFeatures =
        await mapboxMapController?.queryRenderedFeatures(
      RenderedQueryGeometry.fromScreenCoordinate(screenPoint),
      RenderedQueryOptions(
          layerIds: [NotificationLayerService.notificationsUnclusteredLayerId]),
    );

    if (notificationFeatures != null && notificationFeatures.isNotEmpty) {
      // Нажали на отдельное уведомление
      final feature = notificationFeatures.first?.queriedFeature.feature;
      if (feature == null) return;
      final notification =
          notificationLayerService.parseNotificationFromFeature(
              jsonDecode(jsonEncode(feature)) as Map<String, dynamic>);

      if (notification == null) return;

      if (mounted) {
        showBaseBottomSheet(
          context: context,
          child: BlocProvider.value(
            value: getIt<EventsCubit>(),
            child: NotificationInfoDialog(
                eventId: notification.id,
                userId: context.read<UserCubit>().state.user.id,
                onNotRelevantClick: (int value) {
                  context
                      .read<EventsCubit>()
                      .deleteEvent(eventId: value.toString());
                  context.pop();
                }),
          ),
        );
      }

      return;
    }

    final eventFeature = await mapboxMapController?.queryRenderedFeatures(
      RenderedQueryGeometry.fromScreenCoordinate(screenPoint),
      RenderedQueryOptions(
          layerIds: [EventLayerService.eventsUnclusteredLayerId]),
    );
    if (eventFeature != null && eventFeature.isNotEmpty) {
      final feature = eventFeature.first?.queriedFeature.feature;
      if (feature == null) return;
      final event = eventLayerService.parseEventFromFeature(
        jsonDecode(jsonEncode(feature)) as Map<String, dynamic>,
      );

      if (event == null) return;
      if (mounted) {
        showBaseBottomSheet(
          context: context,
          child: EventInfoDialog(
            event: event.toEntity(),
          ),
        );
      }

      return;
    }

    // Проверяем отдельные точки Plan B
    final planBFeatures = await mapboxMapController?.queryRenderedFeatures(
      RenderedQueryGeometry.fromScreenCoordinate(screenPoint),
      RenderedQueryOptions(
          layerIds: [PlanBLayerService.planBCircleLayerId]),
    );

    if (planBFeatures != null && planBFeatures.isNotEmpty) {
      final feature = planBFeatures.first?.queriedFeature.feature;
      if (feature == null) return;
      final planB = planBLayerService.parsePlanBFromFeature(
        jsonDecode(jsonEncode(feature)) as Map<String, dynamic>,
      );

      if (planB == null) return;
      if (mounted) {
        showBaseBottomSheet(
          context: context,
          child: PlanBInfoDialog(
            inClusterList: false,
            planB: planB,
          ),
        );
      }

      return;
    }
  }

  Future<void> onMapTap(MapContentGestureContext gestureContext) async {
    final screenPoint =
        await mapboxMapController?.pixelForCoordinate(gestureContext.point);

    if (screenPoint == null) {
      debugPrint("Не удалось получить screen coordinate");
      return;
    }

    await _onClusterClick(screenPoint);
    await _onPointClick(screenPoint);
  }

  /// Применяет выбранный режим отображения к слоям карты
  Future<void> applyDisplayMode(MapDisplayMode mode) async {
    if (mapboxMapController == null) return;
    
    final style = mapboxMapController!.style;

    switch (mode) {
      case MapDisplayMode.all:
        // Показываем все слои
        await propertyLayerService.showAllLayers(style);
        await planBLayerService.showAllLayers(style);
        await notificationLayerService.showAllLayers(style);
        await eventLayerService.showAllLayers(style);
        break;

      case MapDisplayMode.planBOnly:
        // Показываем только Plan B, скрываем остальные
        await propertyLayerService.hideAllLayers(style);
        await planBLayerService.showAllLayers(style);
        await notificationLayerService.hideAllLayers(style);
        await eventLayerService.hideAllLayers(style);
        break;

      case MapDisplayMode.propertyOnly:
        // Показываем недвижимость и события, скрываем Plan B и уведомления
        await propertyLayerService.showAllLayers(style);
        await planBLayerService.hideAllLayers(style);
        await notificationLayerService.hideAllLayers(style);
        await eventLayerService.showAllLayers(style);
        break;
    }
  }
}
