// dart format width=80
// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// InjectableConfigGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:dio/dio.dart' as _i361;
import 'package:flutter_secure_storage/flutter_secure_storage.dart' as _i558;
import 'package:get_it/get_it.dart' as _i174;
import 'package:injectable/injectable.dart' as _i526;
import 'package:shared_preferences/shared_preferences.dart' as _i460;

import '../../features/auth/data/datasources/auth_remote_data_source.dart'
    as _i107;
import '../../features/auth/data/repositories/auth_repository_impl.dart'
    as _i153;
import '../../features/auth/domain/repositories/auth_repository.dart' as _i787;
import '../../features/auth/presentation/cubits/auth/auth_cubit.dart' as _i235;
import '../../features/chat/data/datasources/community_chat_datasource.dart'
    as _i573;
import '../../features/chat/data/datasources/event_chat_datasource.dart'
    as _i334;
import '../../features/chat/data/repositories/community_chat_repository_impl.dart'
    as _i574;
import '../../features/chat/data/repositories/community_chat_socket_repository_impl.dart'
    as _i351;
import '../../features/chat/data/repositories/event_chat_repository_impl.dart'
    as _i970;
import '../../features/chat/data/repositories/event_chat_socket_repository_impl.dart'
    as _i615;
import '../../features/chat/data/socket/chat_socket.dart' as _i466;
import '../../features/chat/domain/repositories/community_chat_repository.dart'
    as _i250;
import '../../features/chat/domain/repositories/community_chat_socket_repository.dart'
    as _i515;
import '../../features/chat/domain/repositories/event_chat_repository.dart'
    as _i934;
import '../../features/chat/domain/repositories/event_chat_socket_repository.dart'
    as _i580;
import '../../features/chat/presentation/cubits/community_chat/community_chat_cubit.dart'
    as _i519;
import '../../features/chat/presentation/cubits/event_chat/event_chat_cubit.dart'
    as _i638;
import '../../features/community/data/datasources/community_remote_datasource.dart'
    as _i158;
import '../../features/community/data/repositories/community_repository_impl.dart'
    as _i321;
import '../../features/community/domain/repositories/community_repository.dart'
    as _i121;
import '../../features/community/presentation/cubits/community/community_cubit.dart'
    as _i491;
import '../../features/event/data/datasources/event_remote_datasource.dart'
    as _i698;
import '../../features/event/data/datasources/vote_remote_datasource.dart'
    as _i990;
import '../../features/event/data/repositories/event_repository_impl.dart'
    as _i429;
import '../../features/event/data/repositories/vote_repository_impl.dart'
    as _i630;
import '../../features/event/domain/repositories/event_repository.dart'
    as _i660;
import '../../features/event/domain/repositories/vote_repository.dart' as _i221;
import '../../features/event/presentation/cubits/events/events_cubit.dart'
    as _i405;
import '../../features/event/presentation/cubits/vote/vote_cubit.dart' as _i502;
import '../../features/home/data/datasources/home_remote_datasource.dart'
    as _i278;
import '../../features/home/data/repositories/home_repository_impl.dart'
    as _i76;
import '../../features/home/data/services/event_layer_service.dart' as _i346;
import '../../features/home/data/services/map_icon_service.dart' as _i485;
import '../../features/home/data/services/notification_layer_service.dart'
    as _i835;
import '../../features/home/data/services/property_layer_service.dart' as _i166;
import '../../features/home/domain/repositories/home_repository.dart' as _i0;
import '../../features/home/presentation/cubits/auth_location/auth_location_cubit.dart'
    as _i1037;
import '../../features/home/presentation/cubits/community_access_form/community_access_cubit.dart'
    as _i294;
import '../../features/home/presentation/cubits/home/home_cubit.dart' as _i715;
import '../../features/notification/data/datasources/notification_remote_datasource.dart'
    as _i227;
import '../../features/notification/data/repositories/notification_repository_impl.dart'
    as _i407;
import '../../features/notification/domain/repositories/notification_repository.dart'
    as _i630;
import '../../features/notification/presentation/cubits/notification_cubit.dart'
    as _i882;
import '../../features/other_profile/data/datasources/other_profile_remote_datasource.dart'
    as _i459;
import '../../features/other_profile/data/repositories/other_profile_repository_impl.dart'
    as _i593;
import '../../features/other_profile/domain/repositories/other_profile_repository.dart'
    as _i165;
import '../../features/other_profile/presentation/cubits/other_profile/other_profile_cubit.dart'
    as _i375;
import '../../features/other_profile/presentation/cubits/other_properties/other_properties_cubit.dart'
    as _i720;
import '../../features/profile/data/datasources/document_data_source.dart'
    as _i609;
import '../../features/profile/data/repositories/document_repository_impl.dart'
    as _i35;
import '../../features/profile/domain/repository/document_repository.dart'
    as _i375;
import '../../features/profile/presentation/cubits/document/document_cubit.dart'
    as _i936;
import '../../features/profile/presentation/cubits/profile/profile_cubit.dart'
    as _i470;
import '../../features/profile/presentation/cubits/profile_create/profile_create_cubit.dart'
    as _i245;
import '../../features/profile/presentation/cubits/user_verified_properties/user_verified_properties_cubit.dart'
    as _i526;
import '../../features/property/data/datasources/property_remote_datasource.dart'
    as _i954;
import '../../features/property/data/datasources/resource_remote_datasource.dart'
    as _i129;
import '../../features/property/data/repositories/property_repository_impl.dart'
    as _i758;
import '../../features/property/data/repositories/resource_repository_impl.dart'
    as _i41;
import '../../features/property/domain/repositories/property_repository.dart'
    as _i61;
import '../../features/property/domain/repositories/resource_repository.dart'
    as _i50;
import '../../features/property/presentation/cubits/properties/properties_cubit.dart'
    as _i468;
import '../../features/property/presentation/cubits/resources/resources_cubit.dart'
    as _i549;
import '../cubits/fcm/fcm_cubit.dart' as _i791;
import '../cubits/theme/theme_cubit.dart' as _i93;
import '../cubits/user/user_cubit.dart' as _i1067;
import '../cubits/user_location/user_location_cubit.dart' as _i940;
import '../data/datasources/push_remote_datasource.dart' as _i189;
import '../data/datasources/user_location_local_datasource.dart' as _i392;
import '../data/datasources/user_remote_datasource.dart' as _i293;
import '../data/repositories/push_repository_impl.dart' as _i1041;
import '../data/repositories/user_location_repository_impl.dart' as _i247;
import '../data/repositories/user_repository_impl.dart' as _i223;
import '../domain/repositories/push_repository.dart' as _i637;
import '../domain/repositories/user_location_repository.dart' as _i543;
import '../domain/repositories/user_repository.dart' as _i544;
import '../network/dio_client.dart' as _i667;
import '../network/jwt_interceptor.dart' as _i260;
import '../notifications/handlers/event_created_handler.dart' as _i1044;
import '../notifications/handlers/event_joined_handler.dart' as _i643;
import '../notifications/handlers/event_left_handler.dart' as _i636;
import '../notifications/handlers/message_received_handler.dart' as _i89;
import '../notifications/handlers/property_verified_handler.dart' as _i536;
import '../notifications/handlers/user_joined_community_handler.dart' as _i630;
import '../notifications/notification_handler.dart' as _i111;
import '../observers/app_lifecycle_observer.dart' as _i716;
import '../router/app_router.dart' as _i81;
import '../services/auth_service.dart' as _i745;
import '../services/fcm_service.dart' as _i928;
import '../services/image_service.dart' as _i768;
import '../services/internet_connection_service.dart' as _i350;
import '../services/map_service.dart' as _i569;
import '../services/marker_service.dart' as _i45;
import '../services/notification_service.dart' as _i941;
import '../services/snackbar_service.dart' as _i342;
import 'register_module.dart' as _i291;

extension GetItInjectableX on _i174.GetIt {
// initializes the registration of main-scope dependencies inside of GetIt
  Future<_i174.GetIt> init({
    String? environment,
    _i526.EnvironmentFilter? environmentFilter,
  }) async {
    final gh = _i526.GetItHelper(
      this,
      environment,
      environmentFilter,
    );
    final registerModule = _$RegisterModule();
    final networkModule = _$NetworkModule();
    await gh.factoryAsync<_i460.SharedPreferences>(
      () => registerModule.prefs,
      preResolve: true,
    );
    gh.factory<_i485.MapIconService>(() => _i485.MapIconService());
    gh.factory<_i294.CommunityAccessCubit>(() => _i294.CommunityAccessCubit());
    gh.factory<_i245.ProfileCreateCubit>(() => _i245.ProfileCreateCubit());
    gh.singleton<_i558.FlutterSecureStorage>(
        () => registerModule.secureStorage);
    gh.singleton<_i716.AppLifecycleObserver>(
        () => registerModule.appLifecycleObserver);
    gh.singleton<_i361.Dio>(() => networkModule.dio);
    gh.singleton<_i941.NotificationService>(() => _i941.NotificationService());
    gh.singleton<_i928.FCMService>(() => _i928.FCMService());
    gh.singleton<_i350.InternetConnectionService>(
        () => _i350.InternetConnectionService());
    gh.singleton<_i954.PropertyRemoteDataSource>(
        () => _i954.PropertyRemoteDataSourceImpl(gh<_i361.Dio>()));
    gh.singleton<_i93.ThemeCubit>(
        () => _i93.ThemeCubit(gh<_i460.SharedPreferences>()));
    gh.singleton<_i111.NotificationHandler>(
      () => _i1044.EventCreatedHandler(),
      instanceName: 'EVENT_CREATED',
    );
    gh.factory<_i166.PropertyLayerService>(
        () => _i166.PropertyLayerService(gh<_i485.MapIconService>()));
    gh.factory<_i835.NotificationLayerService>(
        () => _i835.NotificationLayerService(gh<_i485.MapIconService>()));
    gh.factory<_i346.EventLayerService>(
        () => _i346.EventLayerService(gh<_i485.MapIconService>()));
    gh.singleton<_i334.EventChatDataSource>(
        () => _i334.EventChatDataSourceImpl(gh<_i361.Dio>()));
    gh.lazySingleton<_i569.MapService>(() => _i569.MapboxService());
    gh.singleton<_i111.NotificationHandler>(
      () => _i536.PropertyVerifiedHandler(),
      instanceName: 'PROPERTY_VERIFIED',
    );
    gh.singleton<_i768.ImageService>(() => _i768.ImageServiceImpl());
    gh.singleton<_i459.OtherProfileRemoteDataSource>(
        () => _i459.OtherProfileRemoteDataSourceImpl(gh<_i361.Dio>()));
    gh.singleton<_i573.CommunityChatDataSource>(
        () => _i573.CommunityChatDataSourceImpl(gh<_i361.Dio>()));
    gh.singleton<_i111.NotificationHandler>(
      () => _i630.UserJoinedCommunityHandler(),
      instanceName: 'USER_JOINED_COMMUNITY',
    );
    gh.singleton<_i278.HomeRemoteDataSource>(
        () => _i278.HomeRemoteDataSourceImpl(gh<_i361.Dio>()));
    gh.singleton<_i129.ResourceRemoteDataSource>(
        () => _i129.ResourceRemoteDataSourceImpl(gh<_i361.Dio>()));
    gh.singleton<_i165.OtherProfileRepository>(() =>
        _i593.OtherProfileRepositoryImpl(
            gh<_i459.OtherProfileRemoteDataSource>()));
    gh.singleton<_i189.PushRemoteDataSource>(
        () => _i189.PushRemoteDataSourceImpl(gh<_i361.Dio>()));
    gh.singleton<_i0.HomeRepository>(
        () => _i76.HomeRepositoryImpl(gh<_i278.HomeRemoteDataSource>()));
    gh.singleton<_i342.SnackbarService>(() => _i342.SnackbarServiceImpl());
    gh.singleton<_i227.NotificationRemoteDataSource>(
        () => _i227.NotificationRemoteDataSourceImpl(gh<_i361.Dio>()));
    gh.singleton<_i111.NotificationHandler>(
      () => _i89.MessageReceivedHandler(),
      instanceName: 'MESSAGE_RECEIVED',
    );
    gh.singleton<_i990.VoteRemoteDatasource>(
        () => _i990.VoteRemoteDatasourceImpl(gh<_i361.Dio>()));
    gh.singleton<_i111.NotificationHandler>(
      () => _i643.EventJoinedHandler(),
      instanceName: 'USER_JOINED_EVENT',
    );
    gh.singleton<_i609.DocumentDataSource>(
        () => _i609.DocumentDataSourceImpl(gh<_i361.Dio>()));
    gh.singleton<_i107.AuthRemoteDataSource>(
        () => _i107.AuthRemoteDataSourceImpl(gh<_i361.Dio>()));
    gh.singleton<_i250.CommunityChatRepository>(() =>
        _i574.CommunityChatRepositoryImpl(gh<_i573.CommunityChatDataSource>()));
    gh.singleton<_i637.PushRepository>(
        () => _i1041.PushRepositoryImpl(gh<_i189.PushRemoteDataSource>()));
    gh.singleton<_i698.EventRemoteDataSource>(
        () => _i698.EventRemoteDataSourceImpl(gh<_i361.Dio>()));
    gh.singleton<_i111.NotificationHandler>(
      () => _i636.EventLeftHandler(),
      instanceName: 'USER_LEFT_EVENT',
    );
    gh.singleton<_i630.NotificationRepository>(() =>
        _i407.NotificationRepositoryImpl(
            gh<_i227.NotificationRemoteDataSource>()));
    gh.singleton<_i293.UserRemoteDataSource>(
        () => _i293.UserRemoteDataSourceImpl(gh<_i361.Dio>()));
    gh.factory<_i45.MarkerService>(() => _i45.MarkerServiceImpl());
    gh.singleton<_i158.CommunityRemoteDataSource>(
        () => _i158.CommunityRemoteDataSourceImpl(gh<_i361.Dio>()));
    gh.singleton<_i375.DocumentRepository>(
        () => _i35.DocumentRepositoryImpl(gh<_i609.DocumentDataSource>()));
    gh.singleton<_i121.CommunityRepository>(() =>
        _i321.CommunityRepositoryImpl(gh<_i158.CommunityRemoteDataSource>()));
    gh.factory<_i936.DocumentCubit>(
        () => _i936.DocumentCubit(gh<_i375.DocumentRepository>()));
    gh.singleton<_i392.UserLocationLocalDataSource>(() =>
        _i392.UserLocationLocalDataSourceImpl(
            gh<_i558.FlutterSecureStorage>()));
    gh.singleton<_i61.PropertyRepository>(() =>
        _i758.PropertyRepositoryImpl(gh<_i954.PropertyRemoteDataSource>()));
    gh.singleton<_i745.AuthService>(
        () => _i745.AuthService(gh<_i558.FlutterSecureStorage>()));
    gh.factory<_i526.UserVerifiedPropertiesCubit>(
        () => _i526.UserVerifiedPropertiesCubit(gh<_i61.PropertyRepository>()));
    gh.singleton<_i468.PropertiesCubit>(
        () => _i468.PropertiesCubit(gh<_i61.PropertyRepository>()));
    gh.singleton<_i544.UserRepository>(
        () => _i223.UserRepositoryImpl(gh<_i293.UserRemoteDataSource>()));
    gh.factory<_i1037.AuthLocationCubit>(
        () => _i1037.AuthLocationCubit(gh<_i0.HomeRepository>()));
    gh.singleton<_i715.HomeCubit>(
        () => _i715.HomeCubit(gh<_i0.HomeRepository>()));
    gh.factory<_i375.OtherProfileCubit>(
        () => _i375.OtherProfileCubit(gh<_i165.OtherProfileRepository>()));
    gh.singleton<_i882.NotificationCubit>(() => _i882.NotificationCubit(
          gh<_i630.NotificationRepository>(),
          gh<_i941.NotificationService>(),
        ));
    gh.singleton<_i50.ResourceRepository>(() =>
        _i41.ResourceRepositoryImpl(gh<_i129.ResourceRemoteDataSource>()));
    gh.singleton<_i491.CommunityCubit>(
        () => _i491.CommunityCubit(gh<_i121.CommunityRepository>()));
    gh.lazySingleton<_i543.UserLocationRepository>(() =>
        _i247.UserLocationRepositoryImpl(
            gh<_i392.UserLocationLocalDataSource>()));
    gh.singleton<_i260.JWTInterceptor>(() => _i260.JWTInterceptor(
          gh<_i361.Dio>(),
          gh<_i745.AuthService>(),
        ));
    gh.singleton<_i221.VoteRepository>(
        () => _i630.VoteRepositoryImpl(gh<_i990.VoteRemoteDatasource>()));
    gh.singleton<_i934.EventChatRepository>(
        () => _i970.EventChatRepositoryImpl(gh<_i334.EventChatDataSource>()));
    gh.singleton<_i791.FcmCubit>(() => _i791.FcmCubit(
          gh<_i637.PushRepository>(),
          gh<_i928.FCMService>(),
        ));
    gh.lazySingleton<_i549.ResourcesCubit>(
        () => _i549.ResourcesCubit(gh<_i50.ResourceRepository>()));
    gh.factory<_i720.OtherPropertiesCubit>(
        () => _i720.OtherPropertiesCubit(gh<_i61.PropertyRepository>()));
    gh.singleton<_i660.EventRepository>(
        () => _i429.EventRepositoryImpl(gh<_i698.EventRemoteDataSource>()));
    gh.singleton<_i787.AuthRepository>(() => _i153.AuthRepositoryImpl(
          gh<_i107.AuthRemoteDataSource>(),
          gh<_i745.AuthService>(),
        ));
    gh.singleton<_i81.AppRouter>(() => _i81.AppRouter(gh<_i745.AuthService>()));
    gh.singleton<_i466.ChatSocket>(
        () => _i466.ChatSocket(gh<_i745.AuthService>()));
    gh.singleton<_i515.CommunityChatSocketRepository>(
        () => _i351.CommunityChatSocketRepositoryImpl(gh<_i466.ChatSocket>()));
    gh.singleton<_i667.DioClient>(() => _i667.DioClient(
          gh<_i361.Dio>(),
          gh<_i260.JWTInterceptor>(),
        ));
    gh.singleton<_i405.EventsCubit>(
        () => _i405.EventsCubit(gh<_i660.EventRepository>()));
    gh.singleton<_i940.UserLocationCubit>(() => _i940.UserLocationCubit(
          gh<_i543.UserLocationRepository>(),
          gh<_i569.MapService>(),
        ));
    gh.singleton<_i1067.UserCubit>(
        () => _i1067.UserCubit(gh<_i544.UserRepository>()));
    gh.factory<_i502.VoteCubit>(
        () => _i502.VoteCubit(gh<_i221.VoteRepository>()));
    gh.singleton<_i519.CommunityChatCubit>(() => _i519.CommunityChatCubit(
          gh<_i250.CommunityChatRepository>(),
          gh<_i515.CommunityChatSocketRepository>(),
        ));
    gh.singleton<_i580.EventChatSocketRepository>(
        () => _i615.EventChatRepositoryImpl(gh<_i466.ChatSocket>()));
    gh.singleton<_i235.AuthCubit>(
        () => _i235.AuthCubit(gh<_i787.AuthRepository>()));
    gh.factory<_i470.ProfileCubit>(
        () => _i470.ProfileCubit(gh<_i787.AuthRepository>()));
    gh.singleton<_i638.EventChatCubit>(() => _i638.EventChatCubit(
          gh<_i934.EventChatRepository>(),
          gh<_i580.EventChatSocketRepository>(),
        ));
    return this;
  }
}

class _$RegisterModule extends _i291.RegisterModule {}

class _$NetworkModule extends _i667.NetworkModule {}
