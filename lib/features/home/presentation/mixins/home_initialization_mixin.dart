import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:neighbours/features/chat/presentation/cubits/chat/chat_cubit.dart';
import 'dart:async';
import 'package:neighbours/core/cubits/events/events_cubit.dart';
import 'package:neighbours/core/cubits/user/user_cubit.dart';
import 'package:neighbours/core/cubits/user_location/user_location_cubit.dart';
import 'package:neighbours/core/exceptions/exceptions.dart';
import 'package:neighbours/core/router/app_routes.dart';
import 'package:neighbours/core/services/map_service.dart';
import 'package:neighbours/core/di/injection.dart';
import 'package:neighbours/features/home/data/services/event_layer_service.dart';
import 'package:neighbours/features/home/data/services/property_layer_service.dart';
import 'package:neighbours/features/home/presentation/pages/home.dart';
import 'package:neighbours/features/notification/presentation/cubits/notification_cubit.dart';
import 'package:neighbours/features/property/presentation/cubits/properties/properties_cubit.dart';
import '../../data/services/notification_layer_service.dart';
import '../cubits/home/home_cubit.dart';

mixin HomeInitializationMixin<T extends StatefulWidget> on State<Home> {
  AppLifecycleState? _lastLifecycleState;
  Timer? _debounceTimer;
  bool _isDataFetching = false;
  DateTime? _lastDataFetchTime;

  MapService get mapService;

  set mapService(MapService service);

  NotificationLayerService get notificationLayerService;

  EventLayerService get eventLayerService;

  PropertyLayerService get propertyLayerService;

  set notificationLayerService(
      NotificationLayerService notificationLayerService);

  set propertyLayerService(PropertyLayerService propertyLayerService);

  set eventLayerService(EventLayerService eventLayerService);

  void initializeServices() {
    mapService = getIt<MapService>();
    notificationLayerService = getIt<NotificationLayerService>();
    propertyLayerService = getIt<PropertyLayerService>();
    eventLayerService = getIt<EventLayerService>();
    mapService.initialize();
    _initializeLifecycleObserver();
  }

  void _initializeLifecycleObserver() {
    _lastLifecycleState = WidgetsBinding.instance.lifecycleState;
  }

  void handleAppLifecycleStateChange(AppLifecycleState state) {
    // Перезагрузка данных при возврате в активное состояние приложения
    if (_lastLifecycleState != null &&
        (_lastLifecycleState == AppLifecycleState.paused ||
            _lastLifecycleState == AppLifecycleState.inactive) &&
        state == AppLifecycleState.resumed) {
      _debouncedDataFetch(firstInit: false);
    }

    _lastLifecycleState = state;
  }

  void _debouncedDataFetch({bool firstInit = true}) {
    // Отменяем предыдущий таймер
    _debounceTimer?.cancel();

    // Проверяем, не выполнялся ли запрос недавно (менее 5 секунд назад)
    if (_lastDataFetchTime != null &&
        DateTime.now().difference(_lastDataFetchTime!).inSeconds < 10) {
      return;
    }

    // Устанавливаем новый таймер с задержкой 500мс
    _debounceTimer = Timer(const Duration(milliseconds: 500), () {
      performDataFetch(firstInit: firstInit);
    });
  }

  Future<void> performDataFetch({bool firstInit = true}) async {
    if (!mounted || _isDataFetching) return;

    _isDataFetching = true;
    _lastDataFetchTime = DateTime.now();

    final homeCubit = context.read<HomeCubit>();
    final userCubit = context.read<UserCubit>();
    final propertiesCubit = context.read<PropertiesCubit>();
    final eventsCubit = context.read<EventsCubit>();
    final locationCubit = context.read<UserLocationCubit>();
    final chatCubit = context.read<ChatCubit>();
    final notificationCubit = context.read<NotificationCubit>();

    try {
      await Future.wait([
        if (firstInit) homeCubit.start(),
        userCubit.fetchUser(),
      ]);
      if (firstInit) {
        chatCubit.fetchUnreadMessageCounts(userCubit.state.user.id);
        notificationCubit.fetchUnreadCount();
        await chatCubit.initializeSocket().then((_) {
          chatCubit.listenEventMessages();
        });
      }
      final community = userCubit.state.user.communities.firstOrNull;

      if (community == null) {
        await propertiesCubit.fetchMyProperties();
      } else {
        await Future.wait([
          propertiesCubit.fetchPropertiesByCommunityId(
            community.id.toString(),
          ),
          eventsCubit.fetchCommunityEvents(
            communityId: community.id.toString(),
          ),
        ]);
      }

      // Загружаем реальную геолокацию параллельно, не блокируя инициализацию
      locationCubit.getPosition();
    } on NetworkException {
      if (!mounted) return;
      context.push(AppRoutePath.noInternet, extra: performDataFetch);
    } catch (e) {
      if (!mounted) return;
      context.push(AppRoutePath.unexpectedError, extra: performDataFetch);
    } finally {
      _isDataFetching = false;
    }
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    super.dispose();
  }
}
