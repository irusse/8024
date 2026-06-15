import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart' hide Error;
import 'package:neighbours/core/components/bottom_sheet_dialog.dart';
import 'package:neighbours/core/components/get_location_dialog.dart';
import 'package:neighbours/core/components/my_location_btn.dart';
import 'package:neighbours/core/cubits/user/user_cubit.dart';
import 'package:neighbours/core/cubits/user_location/user_location_cubit.dart';
import 'package:neighbours/core/error/failures.dart';
import 'package:neighbours/core/extensions/context_ext.dart';
import 'package:neighbours/core/router/app_routes.dart';
import 'package:neighbours/core/services/map_service.dart';
import 'package:neighbours/core/state/api_state.dart';
import 'package:neighbours/core/utils/map_camera_utils.dart';
import 'package:neighbours/features/chat/presentation/cubits/community_chat/community_chat_cubit.dart';
import 'package:neighbours/features/chat/presentation/cubits/event_chat/event_chat_cubit.dart';
import 'package:neighbours/features/community/presentation/cubits/community/community_cubit.dart';
import 'package:neighbours/features/event/presentation/cubits/events/events_cubit.dart';
import 'package:neighbours/features/home/data/services/event_layer_service.dart';
import 'package:neighbours/features/home/data/services/property_layer_service.dart';
import 'package:neighbours/features/home/data/services/plan_b_layer_service.dart';
import 'package:neighbours/features/home/domain/enums/map_display_mode.dart';
import 'package:neighbours/features/plan_b/presentation/cubits/plan_b/plan_b_cubit.dart';
import 'package:neighbours/features/home/presentation/managers/step_sheet_manager.dart';
import 'package:neighbours/features/home/presentation/widgets/add_event_button.dart';
import 'package:neighbours/features/home/presentation/widgets/generic_list_view.dart';
import 'package:neighbours/features/home/presentation/widgets/property_marker.dart';
import 'package:neighbours/features/home/presentation/widgets/bottom_panel.dart';
import 'package:neighbours/features/home/presentation/widgets/chat_btn.dart';
import 'package:neighbours/features/home/presentation/widgets/home_map.dart';
import 'package:neighbours/features/home/presentation/widgets/set_location_dialog.dart';
import 'package:neighbours/features/home/presentation/widgets/top_panel.dart';
import 'package:neighbours/features/home/presentation/mixins/home_map_mixin.dart';
import 'package:neighbours/features/home/presentation/mixins/home_initialization_mixin.dart';
import 'package:neighbours/features/home/presentation/widgets/view_switcher.dart';
import 'package:neighbours/features/property/presentation/cubits/properties/properties_cubit.dart';
import 'package:neighbours/features/property/presentation/cubits/property_form/property_form_cubit.dart';
import '../../../../core/cubits/theme/theme_cubit.dart';
import '../../data/services/notification_layer_service.dart';
import '../cubits/home/home_cubit.dart';
import '../widgets/home_loading_overlay.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home>
    with
        StepSheetManager<Home>,
        HomeInitializationMixin<Home>,
        HomeMapMixin<Home>,
        WidgetsBindingObserver {
  MapboxMap? _mapboxMapController;
  final ValueNotifier<int> _viewSwitcherNotifier = ValueNotifier<int>(0);

  // Services
  late MapService _mapService;
  late NotificationLayerService _notificationLayerService;
  late PropertyLayerService _propertyLayerService;
  late EventLayerService _eventLayerService;
  late PlanBLayerService _planBLayerService;

  // HomeMapMixin implementation
  @override
  MapboxMap? get mapboxMapController => _mapboxMapController;

  @override
  set mapboxMapController(MapboxMap? controller) =>
      _mapboxMapController = controller;

  @override
  set notificationLayerService(
          NotificationLayerService notificationLayerService) =>
      _notificationLayerService = notificationLayerService;

  @override
  set eventLayerService(EventLayerService eventLayerService) =>
      _eventLayerService = eventLayerService;

  @override
  set propertyLayerService(PropertyLayerService propertyLayerService) =>
      _propertyLayerService = propertyLayerService;

  @override
  set planBLayerService(PlanBLayerService planBLayerService) =>
      _planBLayerService = planBLayerService;

  // HomeInitializationMixin implementation
  @override
  MapService get mapService => _mapService;

  @override
  set mapService(MapService service) => _mapService = service;

  @override
  NotificationLayerService get notificationLayerService =>
      _notificationLayerService;

  @override
  EventLayerService get eventLayerService => _eventLayerService;

  @override
  PropertyLayerService get propertyLayerService => _propertyLayerService;

  @override
  PlanBLayerService get planBLayerService => _planBLayerService;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    initializeServices();
    prepareInitialCamera();
    performDataFetch();
    _viewSwitcherNotifier.addListener(_onViewSwitcherChanged);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _viewSwitcherNotifier.removeListener(_onViewSwitcherChanged);
    _viewSwitcherNotifier.dispose();
    disposeMapResources();
    super.dispose();
  }

  void _onViewSwitcherChanged() {
    if (_viewSwitcherNotifier.value == 1) {
      _showBottomSheet();
    }
  }

  void _showBottomSheet() {
    final homeCubit = context.read<HomeCubit>();
    final displayMode = homeCubit.displayMode;

    if (displayMode == MapDisplayMode.planBOnly) {
      // Показываем список Plan B
      showBaseBottomSheet(
        context: context,
        child: GenericListView(
          items: context.read<PlanBCubit>().state.items,
        ),
      ).then((_) {
        _viewSwitcherNotifier.value = 0;
      });
    } else {
      // Показываем список объектов недвижимости
      showBaseBottomSheet(
        context: context,
        child: GenericListView(
          items:
              context.read<PropertiesCubit>().state.properties.values.toList(),
        ),
      ).then((_) {
        _viewSwitcherNotifier.value = 0;
      });
    }
  }

  void _showLocationDisabledDialog(BuildContext context) async {
    await showBaseBottomSheet(
        context: context,
        title: 'Где вы находитесь',
        child: BlocProvider.value(
          value: context.read<UserLocationCubit>(),
          child: const GetLocationDialog(),
        ));
  }

  @override
  Widget build(BuildContext context) {
    final userId =
        context.select<UserCubit, int>((cubit) => cubit.state.user.id);
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        final homeCubit = context.read<HomeCubit>();
        final state = homeCubit.state;

        if (state is ShowSetCoordinates) {
          homeCubit.setIdle();
          return;
        }
        if (context.canPop()) {
          context.pop(result);
        }
      },
      child: Scaffold(
        body: BlocConsumer<HomeCubit, HomeState>(
          listenWhen: (prev, curr) => prev.runtimeType != curr.runtimeType,
          listener: (context, state) {
            if (state is Error) {
              context.snackbar.error(context, state.message);
            } else if (state is NetworkError) {
              context.push(AppRoutePath.noInternet,
                  extra: () => performDataFetch(firstInit: true));
            } else if (state is GetStepError) {
              context.push(AppRoutePath.unexpectedError,
                  extra: performDataFetch);
            }
            showStepSheet(context, state,
                onDataFetchRequired: performDataFetch);
          },
          builder: (context, state) {
            final showMarker = context.read<HomeCubit>().isMarkerVisible();

            return MultiBlocListener(
              listeners: [
                BlocListener<HomeCubit, HomeState>(
                  listener: (context, state) {
                    if (state is MapDisplayModeChanged) {
                      applyDisplayMode(state.mode);
                    }
                  },
                ),
                BlocListener<ThemeCubit, ThemeState>(
                  listenWhen: (prev, curr) => prev.isDark != curr.isDark,
                  listener: (context, state) async {
                    if (_mapboxMapController != null) {
                      await _mapboxMapController!
                          .loadStyleURI(context.read<ThemeCubit>().getThemeMap);
                    }
                  },
                ),
                BlocListener<UserLocationCubit, UserLocationState>(
                    listener: (context, locationState) {
                  locationState.maybeWhen(
                    permissionDenied: () =>
                        _showLocationDisabledDialog(context),
                    permissionDeniedForever: () =>
                        _showLocationDisabledDialog(context),
                    locationReceived: (coordinates, _) {
                      MapCameraUtils.flyToPosition(
                        mapboxMapController!,
                        coordinates.latitude,
                        coordinates.longitude,
                      );
                    },
                    orElse: () {},
                  );
                }),
                BlocListener<UserCubit, UserState>(
                  listenWhen: (prev, curr) =>
                      prev.fetchState != curr.fetchState,
                  listener: (context, state) {
                    state.fetchState.mapOrNull(
                        failure: (error) =>
                            context.snackbar.error(context, error.message));
                  },
                ),
                BlocListener<PropertiesCubit, PropertiesState>(
                  listenWhen: (prev, curr) =>
                      prev.properties != curr.properties,
                  listener: (context, propertiesState) {
                    propertyLayerService.updateData(context,
                        mapboxMapController, propertiesState.properties);
                  },
                ),
                BlocListener<PlanBCubit, PlanBState>(
                  listenWhen: (prev, curr) => prev.items != curr.items,
                  listener: (context, planBState) {
                    planBLayerService.updateData(
                      context,
                      mapboxMapController,
                      planBState.items,
                    );
                  },
                ),
                BlocListener<EventsCubit, EventsState>(
                  listener: (context, state) {
                    final chatCubit = context.read<EventChatCubit>();

                    state.joinEventState.mapOrNull(success: (res) {
                      chatCubit.joinEvent(res.data.id);
                    }, failure: (failure) {
                      if (failure is NotFoundFailure) {
                        context.snackbar.error(context,
                            "Не удалось найти событие.\nВозможно оно было удалено");
                      }
                    });
                    state.createEventState.mapOrNull(success: (res) {
                      chatCubit.joinEvent(res.data.id);
                    });
                    state.createNotificationState.mapOrNull(success: (res) {
                      chatCubit.joinEvent(res.data.id);
                    });
                    state.leaveEventState.mapOrNull(success: (res) {
                      chatCubit
                        ..leaveEvent(res.data.id)
                        ..removeEventCount(res.data.id);
                    }, failure: (failure) {
                      if (failure is NotFoundFailure) {
                        context.snackbar.error(context,
                            "Не удалось найти событие.\nВозможно оно было удалено");
                      }
                    });
                    state.deleteState.maybeWhen(
                      success: (eventId) => chatCubit.leaveEvent(eventId),
                      failure: (message) {
                        context.snackbar.error(context, message);
                      },
                      orElse: () {},
                    );

                    state.fetchState.maybeWhen(
                        failure: (message) {
                          context.snackbar.error(context, message);
                        },
                        success: (events) {
                          for (final event in events) {
                            if (event.creator.id == userId ||
                                event.participants.any((p) => p.id == userId)) {
                              chatCubit.joinEvent(event.id);
                            }
                          }
                        },
                        orElse: () {});
                  },
                ),
                BlocListener<CommunityCubit, CommunityState>(
                  listenWhen: (prev, curr) =>
                      prev.communities != curr.communities,
                  listener: (context, state) async {
                    final chatCubit = context.read<CommunityChatCubit>();
                    print(state.communities);
                    for (final community in state.communities) {
                      chatCubit.join(community.id);
                    }
                  },
                ),
                BlocListener<EventsCubit, EventsState>(
                  listenWhen: (prev, curr) => prev.events != curr.events,
                  listener: (context, eventsState) {
                    final events = context.read<EventsCubit>().allFullEvents();
                    final notifications =
                        context.read<EventsCubit>().allNotifications();
                    eventLayerService.updateData(mapboxMapController, events);
                    notificationLayerService.updateData(
                        mapboxMapController, notifications);
                  },
                ),
              ],
              child: Stack(
                children: [
                  ValueListenableBuilder<bool>(
                    valueListenable: isMapReadyNotifier,
                    builder: (context, isReady, child) {
                      if (!isReady) {
                        return const HomeLoadingOverlay();
                      }
                      return HomeMapView(
                        initialCameraOptions: initialCameraOptions,
                        onMapCreated: onMapCreated,
                        onMapTap: onMapTap,
                        onStyleLoadedListener: (s) =>
                            reinitializeLayersAfterThemeChange(),
                      );
                    },
                  ),
                  if (showMarker) const PropertyMarker(),
                  Positioned(
                    top: MediaQuery.of(context).padding.top + 10,
                    left: 16,
                    right: 16,
                    child: const TopPanel(),
                  ),
                  Positioned(
                      bottom: MediaQuery.of(context).size.height / 4,
                      right: 8,
                      child: ViewSwitcher(notifier: _viewSwitcherNotifier)),
                  Positioned(
                    bottom: MediaQuery.of(context).padding.bottom + 80,
                    right: 8,
                    child: ChatButton(),
                  ),
                  Positioned(
                    bottom: MediaQuery.of(context).padding.bottom + 80,
                    left: 8,
                    child: AddEventButton(),
                  ),
                  Positioned(
                    bottom: MediaQuery.of(context).padding.bottom + 16,
                    left: 0,
                    right: 0,
                    child: BottomPanel(
                      navigateToProperty: (lat, lng) =>
                          MapCameraUtils.flyToPosition(
                              mapboxMapController!, lat, lng),
                    ),
                  ),
                  MyLocationBtn(
                    bottom: MediaQuery.of(context).size.height / 2.5,
                    onClick: () =>
                        context.read<UserLocationCubit>().getPosition(),
                  ),
                  if (state is ShowSetCoordinates)
                    SetCoordinates(
                      onClick: () async {
                        if (_mapboxMapController == null) return;
                        final camera =
                            await _mapboxMapController!.getCameraState();
                        final center = camera.center;
                        final coordinates = LatLng(
                            center.coordinates.lat.toDouble(),
                            center.coordinates.lng.toDouble());
                        if (context.mounted) {
                          context
                              .read<PropertyFormCubit>()
                              .setCoordinates(coordinates);
                          context.read<HomeCubit>().goToAddPropertyStep();
                        }
                      },
                    ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
