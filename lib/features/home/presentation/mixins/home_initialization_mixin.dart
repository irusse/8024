import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:neighbours/core/cubits/fcm/fcm_cubit.dart';
import 'dart:async';
import 'package:neighbours/core/cubits/user/user_cubit.dart';
import 'package:neighbours/core/cubits/user_location/user_location_cubit.dart';
import 'package:neighbours/core/exceptions/exceptions.dart';
import 'package:neighbours/core/router/app_routes.dart';
import 'package:neighbours/core/services/map_service.dart';
import 'package:neighbours/core/di/injection.dart';
import 'package:neighbours/features/chat/data/socket/chat_socket.dart';
import 'package:neighbours/features/chat/presentation/cubits/community_chat/community_chat_cubit.dart';
import 'package:neighbours/features/chat/presentation/cubits/event_chat/event_chat_cubit.dart';
import 'package:neighbours/features/chat/presentation/cubits/private_chat/private_chat_cubit.dart';
import 'package:neighbours/features/community/presentation/cubits/community/community_cubit.dart';
import 'package:neighbours/features/event/presentation/cubits/events/events_cubit.dart';
import 'package:neighbours/features/home/data/services/event_layer_service.dart';
import 'package:neighbours/features/home/data/services/property_layer_service.dart';
import 'package:neighbours/features/home/data/services/plan_b_layer_service.dart';
import 'package:neighbours/features/home/presentation/pages/home.dart';
import 'package:neighbours/features/notification/presentation/cubits/notification_cubit.dart';
import 'package:neighbours/features/property/presentation/cubits/properties/properties_cubit.dart';
import 'package:neighbours/features/plan_b/presentation/cubits/plan_b/plan_b_cubit.dart';
import '../../data/services/notification_layer_service.dart';
import '../cubits/home/home_cubit.dart';

mixin HomeInitializationMixin<T extends StatefulWidget> on State<Home> {
  MapService get mapService;

  set mapService(MapService service);

  NotificationLayerService get notificationLayerService;

  EventLayerService get eventLayerService;

  PropertyLayerService get propertyLayerService;

  PlanBLayerService get planBLayerService;

  set notificationLayerService(
      NotificationLayerService notificationLayerService);

  set propertyLayerService(PropertyLayerService propertyLayerService);

  set planBLayerService(PlanBLayerService planBLayerService);

  set eventLayerService(EventLayerService eventLayerService);

  void initializeServices() {
    mapService = getIt<MapService>();
    notificationLayerService = getIt<NotificationLayerService>();
    propertyLayerService = getIt<PropertyLayerService>();
    planBLayerService = getIt<PlanBLayerService>();
    eventLayerService = getIt<EventLayerService>();
    mapService.initialize();
  }

  Future<void> performDataFetch({bool firstInit = true}) async {
    if (!mounted) return;

    final homeCubit = context.read<HomeCubit>();
    final userCubit = context.read<UserCubit>();
    final propertiesCubit = context.read<PropertiesCubit>();
    final eventsCubit = context.read<EventsCubit>();
    final locationCubit = context.read<UserLocationCubit>();
    final eventChatCubit = context.read<EventChatCubit>();
    final communityChatCubit = context.read<CommunityChatCubit>();
    final communitiesCubit = context.read<CommunityCubit>();
    final notificationCubit = context.read<NotificationCubit>();
    final privateChatCubit = context.read<PrivateChatCubit>();
    final planBCubit = context.read<PlanBCubit>();

    try {
      await Future.wait([
        if (firstInit) homeCubit.start(),
        userCubit.fetchUser(),
      ]);
      communitiesCubit.setCommunitiesLocally(userCubit.state.user.communities);
      privateChatCubit.fetchPrivateConversations();
      if (firstInit) {
         await planBCubit.getMapItems();
        await getIt<ChatSocket>().initializeSocket().then((_) {
          eventChatCubit.listenEventMessages();
          communityChatCubit.listenCommunityMessages();
          privateChatCubit.listenPrivateMessages(userCubit.state.user.id);
        });
        eventChatCubit.fetchUnreadMessageCounts(userCubit.state.user.id);
        communityChatCubit.fetchUnreadMessageCounts(userCubit.state.user.id);
        getIt<FcmCubit>().saveFcmToken();

        notificationCubit.fetchUnreadCount();
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
      locationCubit.getPosition();
    } on NetworkException {
      if (!mounted) return;
      context.push(AppRoutePath.noInternet, extra: performDataFetch);
    } catch (e) {
      if (!mounted) return;
      context.push(AppRoutePath.unexpectedError, extra: performDataFetch);
    }
  }

  @override
  void dispose() {
    super.dispose();
  }
}
