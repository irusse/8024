import 'package:chucker_flutter/chucker_flutter.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:injectable/injectable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:neighbours/core/components/full_screen_map_view.dart';
import 'package:neighbours/core/components/lost_connection_screen.dart';
import 'package:neighbours/core/components/unexpected_error_screen.dart';
import 'package:neighbours/core/cubits/chat/chat_cubit.dart';
import 'package:neighbours/core/cubits/events/events_cubit.dart';
import 'package:neighbours/core/cubits/properties/properties_cubit.dart';
import 'package:neighbours/core/cubits/property_form/property_form_cubit.dart';
import 'package:neighbours/core/cubits/user/user_cubit.dart';
import 'package:neighbours/core/cubits/user_location/user_location_cubit.dart';
import 'package:neighbours/core/domain/entities/community/community_entity.dart';
import 'package:neighbours/core/domain/entities/event/event_entity.dart';
import 'package:neighbours/core/domain/entities/property/property_entity.dart';
import 'package:neighbours/core/extensions/context_ext.dart';
import 'package:neighbours/core/router/custom_page_transition.dart';
import 'package:neighbours/core/services/map_service.dart';
import 'package:neighbours/core/state/api_state.dart';
import 'package:neighbours/features/auth/presentation/cubits/auth/auth_cubit.dart';
import 'package:neighbours/features/auth/presentation/cubits/otp/otp_cubit.dart';
import 'package:neighbours/features/auth/presentation/pages/auth_welcome_page.dart';
import 'package:neighbours/features/auth/presentation/pages/country_code_select.dart';
import 'package:neighbours/features/chat/presentation/screens/chat_list.dart';
import 'package:neighbours/features/community/presentation/cubits/community/community_cubit.dart';
import 'package:neighbours/features/community/presentation/screens/community.dart';
import 'package:neighbours/features/event/presentation/cubits/event_form/event_form_cubit.dart';
import 'package:neighbours/features/event/presentation/cubits/notification_form/notification_form_cubit.dart';
import 'package:neighbours/features/event/presentation/cubits/vote/vote_cubit.dart';
import 'package:neighbours/features/event/presentation/screens/event_details.dart';
import 'package:neighbours/features/event/presentation/screens/event_form.dart';
import 'package:neighbours/features/event/presentation/screens/notification_form.dart';
import 'package:neighbours/features/home/presentation/pages/home.dart';
import 'package:neighbours/features/profile/presentation/cubits/document/document_cubit.dart';
import 'package:neighbours/features/profile/presentation/cubits/edit_profile/edit_profile_cubit.dart';
import 'package:neighbours/features/profile/presentation/cubits/profile/profile_cubit.dart';
import 'package:neighbours/features/profile/presentation/cubits/user_verified_properties/user_verified_properties_cubit.dart';
import 'package:neighbours/features/profile/presentation/pages/document_page.dart';
import 'package:neighbours/features/profile/presentation/pages/property_verifications.dart';
import 'package:neighbours/features/profile/presentation/pages/settings.dart';
import 'package:neighbours/features/profile/presentation/pages/user_events.dart';
import 'package:neighbours/features/property/presentation/cubits/resource_form/resource_form_cubit.dart';
import 'package:neighbours/features/property/presentation/cubits/resources/resources_cubit.dart';
import 'package:neighbours/features/property/presentation/screens/edit_property.dart';
import 'package:neighbours/features/property/presentation/screens/property_details.dart';
import 'package:neighbours/features/property/presentation/screens/resource_form.dart';
import '../../features/auth/presentation/pages/phone_auth_page.dart';
import '../../features/chat/presentation/screens/chat.dart';
import '../../features/home/presentation/cubits/home/home_cubit.dart';
import '../../features/profile/presentation/pages/profile_screen.dart';
import '../../features/property/domain/entities/resource/resource_entity.dart';
import '../di/injection.dart';
import '../../features/auth/presentation/pages/sms_code_page.dart';
import '../../features/splash/presentation/pages/splash_screen.dart';
import '../../features/profile/presentation/pages/edit_profile_screen.dart';
import '../services/snackbar_service.dart';
import 'app_routes.dart';

@singleton
class AppRouter {
  late final GoRouter router;

  AppRouter() {
    router = GoRouter(
      observers: [ChuckerFlutter.navigatorObserver],
      initialLocation: AppRoutePath.splash,
      routes: [
        GoRoute(
            path: AppRoutePath.splash,
            builder: (context, state) => const SplashScreen()),
        GoRoute(
            path: AppRoutePath.fullMapPreview,
            pageBuilder: (context, state) {
              final latLng = state.extra as LatLng;
              return CustomPageTransition.slideFromRight(
                key: state.pageKey,
                child: FullScreenMapView(
                    latitude: latLng.latitude, longitude: latLng.longitude),
              );
            }),
        GoRoute(
            path: AppRoutePath.eventDetails,
            pageBuilder: (context, state) {
              final FullEvent event = state.extra as FullEvent;
              return CustomPageTransition.slideFromBottom(
                child: MultiBlocProvider(providers: [
                  BlocProvider.value(value: getIt<EventsCubit>()),
                  BlocProvider.value(value: getIt<UserCubit>()),
                  BlocProvider.value(value: getIt<ChatCubit>()),
                  BlocProvider<VoteCubit>(
                    create: (_) => getIt<VoteCubit>(),
                  ),
                ], child: EventDetails(event: event)),
              );
            }),
        GoRoute(
            path: AppRoutePath.communityInfo,
            pageBuilder: (context, state) {
              final CommunityEntity communityEntity =
                  state.extra as CommunityEntity;
              return CustomPageTransition.slideFromRight(
                key: state.pageKey,
                child: MultiBlocProvider(providers: [
                  BlocProvider.value(value: getIt<EventsCubit>()),
                  BlocProvider.value(value: getIt<UserCubit>()),
                  BlocProvider(
                    create: (_) => getIt<CommunityCubit>(),
                  ),
                ], child: Community(communityEntity: communityEntity)),
              );
            }),
        GoRoute(
            path: AppRoutePath.noInternet,
            builder: (context, state) {
              final VoidCallback? retryCallback = state.extra as VoidCallback?;

              return LostConnectionScreen(onRetry: () {
                context.pop();
                if (retryCallback != null) {
                  retryCallback();
                }
              });
            }),
        GoRoute(
            path: AppRoutePath.unexpectedError,
            builder: (context, state) {
              final VoidCallback? retryCallback = state.extra as VoidCallback?;

              return UnexpectedErrorScreen(onRetry: () {
                context.pop();
                if (retryCallback != null) {
                  retryCallback();
                }
              });
            }),
        GoRoute(
          path: AppRoutePath.authWelcome,
          builder: (context, state) => const AuthWelcomePage(),
        ),
        GoRoute(
          path: AppRoutePath.countryCodeSelect,
          name: AppRoutePath.countryCodeSelect,
          pageBuilder: (context, state) {
            final authCubit = getIt<AuthCubit>();
            return CustomPageTransition.slideFromRight(
                child: BlocProvider<AuthCubit>.value(
              value: authCubit,
              child: const CountryCodeSelect(),
            ));
          },
        ),
        GoRoute(
          path: AppRoutePath.login,
          pageBuilder: (context, state) => CustomPageTransition.slideFromRight(
            child: BlocProvider<AuthCubit>(
              create: (_) => getIt<AuthCubit>(),
              child: const PhoneAuthPage(),
            ),
          ),
        ),
        GoRoute(
          path: AppRoutePath.sms,
          pageBuilder: (context, state) {
            final phone = state.pathParameters['phone']!;
            return CustomPageTransition.slideFromRight(
                child: MultiBlocProvider(
                    providers: [
                  BlocProvider.value(value: getIt<AuthCubit>()),
                  BlocProvider<OtpCubit>(
                    create: (_) => OtpCubit(),
                  )
                ],
                    child: BlocConsumer<AuthCubit, AuthState>(
                      listener: (context, state) {
                        if (state.isAuthenticated) {
                          context.go(AppRoutePath.home);
                        }
                        if (state.resendState.isSuccess) {
                          if (state.smsCode != null) {
                            context.snackbar.info(
                              context,
                              'Код для тестирования: ${state.smsCode}',
                              position: SnackBarPosition.top,
                            );
                          }
                        }
                      },
                      builder: (context, state) {
                        return SmsCodePage(
                          isLoading: state.loginState.isLoading ||
                              state.verifyState.isLoading ||
                              state.resendState.isLoading,
                          isError: state.loginState.isFailure ||
                              state.verifyState.isFailure ||
                              state.resendState.isFailure,
                          phone: phone,
                          onCodeCompleted: (code) => context
                              .read<AuthCubit>()
                              .verifySmsCode(phone, code),
                          onRetry: (phone) =>
                              context.read<AuthCubit>().resendOtp(),
                        );
                      },
                    )));
          },
        ),
        GoRoute(
          path: AppRoutePath.chatListPage,
          routes: [
            GoRoute(
                path: AppRoutePath.chatPage,
                pageBuilder: (context, state) {
                  final eventId = int.parse(state.pathParameters['eventId']!);
                  final eventTitle =
                      state.pathParameters['eventTitle'] ?? 'Чат';

                  return CustomPageTransition.slideFromRight(
                      child: MultiBlocProvider(
                    providers: [
                      BlocProvider.value(
                        value: getIt<ChatCubit>(),
                      ),
                      BlocProvider.value(value: getIt<UserCubit>()),
                    ],
                    child: Chat(
                      eventId: eventId,
                      eventTitle: eventTitle,
                    ),
                  ));
                }),
          ],
          pageBuilder: (context, state) {
            return CustomPageTransition.slideFromRight(
                child: MultiBlocProvider(providers: [
              BlocProvider.value(value: getIt<EventsCubit>()),
              BlocProvider.value(value: getIt<ChatCubit>()),
              BlocProvider.value(value: getIt<UserCubit>()),
            ], child: const ChatList()));
          },
        ),
        GoRoute(
          path: AppRoutePath.notificationForm,
          pageBuilder: (context, state) {
            final notificationEvent = state.extra as NotificationEvent?;
            return CustomPageTransition.slideFromBottom(
              child: MultiBlocProvider(providers: [
                BlocProvider.value(value: getIt<UserLocationCubit>()),
                BlocProvider.value(value: getIt<UserCubit>()),
                BlocProvider.value(value: getIt<EventsCubit>()),
                BlocProvider(
                    create: (_) =>
                        NotificationFormCubit(event: notificationEvent)),
              ], child: const NotificationForm()),
            );
          },
        ),
        GoRoute(
          path: AppRoutePath.eventForm,
          pageBuilder: (context, state) {
            final event = state.extra as FullEvent?;
            return CustomPageTransition.slideFromBottom(
              child: MultiBlocProvider(providers: [
                BlocProvider.value(value: getIt<UserLocationCubit>()),
                BlocProvider.value(value: getIt<UserCubit>()),
                BlocProvider.value(value: getIt<EventsCubit>()),
                BlocProvider(create: (_) => EventFormCubit(event: event)),
              ], child: const EventForm()),
            );
          },
        ),
        GoRoute(
          path: AppRoutePath.home,
          builder: (context, state) => MultiBlocProvider(providers: [
            BlocProvider(create: (_) => PropertyFormCubit()),
            BlocProvider.value(
              value: getIt<HomeCubit>(),
            ),
            BlocProvider.value(value: getIt<EventsCubit>()),
            BlocProvider.value(
              value: getIt<UserCubit>(),
            ),
            BlocProvider.value(
              value: getIt<ChatCubit>(),
            ),
            BlocProvider.value(
              value: getIt<UserLocationCubit>(),
            ),
            BlocProvider.value(
              value: getIt<PropertiesCubit>(),
            ),
          ], child: const Home()),
        ),
        GoRoute(
          path: AppRoutePath.propertyDetails,
          pageBuilder: (context, state) {
            final propertyId = int.parse(state.pathParameters['propertyId']!);
            return CustomPageTransition.slideFromRight(
              child: MultiBlocProvider(
                providers: [
                  BlocProvider.value(
                    value: getIt<PropertiesCubit>(),
                  ),
                  BlocProvider.value(
                    value: getIt<UserCubit>(),
                  ),
                  BlocProvider.value(
                    value: getIt<UserLocationCubit>(),
                  ),
                  BlocProvider.value(
                    value: getIt<ResourcesCubit>(),
                  ),
                ],
                child: PropertyDetails(
                  propertyId: propertyId,
                ),
              ),
            );
          },
          routes: [
            GoRoute(
              path: AppRoutePath.resourceForm,
              pageBuilder: (context, state) {
                final propertyId =
                    int.parse(state.pathParameters['propertyId']!);
                final resource = state.extra as ResourceEntity?;
                return CustomPageTransition.slideFromRight(
                  key: state.pageKey,
                  child: MultiBlocProvider(providers: [
                    BlocProvider(
                      create: (_) => ResourceFormCubit(resource: resource)
                        ..setPropertyId(propertyId),
                    ),
                    BlocProvider.value(
                      value: getIt<ResourcesCubit>(),
                    )
                  ], child: const ResourceForm()),
                );
              },
            ),
            GoRoute(
              path: AppRoutePath.propertyEdit,
              pageBuilder: (context, state) {
                final property = state.extra as PropertyEntity?;
                return CustomPageTransition.slideFromBottom(
                  child: MultiBlocProvider(
                    providers: [
                      BlocProvider(
                        create: (_) => PropertyFormCubit(property: property),
                      ),
                      BlocProvider.value(
                        value: getIt<PropertiesCubit>(),
                      ),
                      BlocProvider.value(
                        value: getIt<UserLocationCubit>(),
                      ),
                    ],
                    child: const EditProperty(),
                  ),
                );
              },
            ),
          ],
        ),
        GoRoute(
            path: AppRoutePath.profile,
            pageBuilder: (context, state) => CustomPageTransition.slideFromLeft(
                  key: state.pageKey,
                  child: MultiBlocProvider(
                    providers: [
                      BlocProvider(
                        create: (_) => getIt<ProfileCubit>(),
                      ),
                      BlocProvider.value(
                        value: getIt<UserCubit>(),
                      ),
                      BlocProvider.value(value: getIt<PropertiesCubit>()),
                      BlocProvider.value(value: getIt<EventsCubit>())
                    ],
                    child: const ProfileScreen(),
                  ),
                ),
            routes: [
              GoRoute(
                path: AppRoutePath.editProfile,
                pageBuilder: (context, state) =>
                    CustomPageTransition.slideFromRight(
                  key: state.pageKey,
                  child: MultiBlocProvider(providers: [
                    BlocProvider.value(
                      value: getIt<UserCubit>(),
                    ),
                    BlocProvider.value(
                      value: getIt<UserLocationCubit>(),
                    ),
                    BlocProvider(
                      create: (_) =>
                          EditProfileCubit(getIt<UserCubit>().state.user),
                    ),
                  ], child: const EditProfileScreen()),
                ),
              ),
              GoRoute(
                  path: AppRoutePath.settingsPage,
                  pageBuilder: (context, state) {
                    return CustomPageTransition.slideFromRight(
                      key: state.pageKey,
                      child: BlocProvider.value(
                        value: getIt<UserCubit>(),
                        child: const Settings(),
                      ),
                    );
                  },
                  routes: [
                    GoRoute(
                      path: AppRoutePath.deleteSmsCode,
                      pageBuilder: (context, state) =>
                          CustomPageTransition.slideFromRight(
                        child: MultiBlocProvider(
                            providers: [
                              BlocProvider.value(
                                value: getIt<UserCubit>(),
                              ),
                              BlocProvider<OtpCubit>(
                                create: (_) => OtpCubit(),
                              )
                            ],
                            child: BlocConsumer<UserCubit, UserState>(
                              listener: (context, state) {
                                if (state.confirmProfileDeletion.isSuccess) {
                                  context.pop();
                                }
                                if (state.requestProfileDeletion.isSuccess) {
                                  final code = state.deletionRequestCode;
                                  context.snackbar.info(
                                      context, 'Код для тестирования: $code',
                                      position: SnackBarPosition.top);
                                }
                              },
                              builder: (context, state) => SmsCodePage(
                                  phone: getIt<UserCubit>().state.user.phone,
                                  onCodeCompleted: (code) => context
                                      .read<UserCubit>()
                                      .confirmProfileDeletion(code),
                                  onRetry: (phone) => context
                                      .read<UserCubit>()
                                      .requestProfileDeletion(),
                                  isError: context
                                      .read<UserCubit>()
                                      .state
                                      .confirmProfileDeletion
                                      .isFailure,
                                  isLoading: context
                                      .read<UserCubit>()
                                      .state
                                      .confirmProfileDeletion
                                      .isLoading),
                            )),
                      ),
                    ),
                  ]),
              GoRoute(
                path: AppRoutePath.myEvents,
                pageBuilder: (context, state) =>
                    CustomPageTransition.slideFromRight(
                  child: MultiBlocProvider(providers: [
                    BlocProvider.value(
                      value: getIt<UserCubit>(),
                    ),
                    BlocProvider.value(
                      value: getIt<EventsCubit>(),
                    ),
                  ], child: const UserEvents()),
                ),
              ),
              GoRoute(
                path: AppRoutePath.propertyVerifications,
                pageBuilder: (context, state) =>
                    CustomPageTransition.slideFromRight(
                  child: MultiBlocProvider(providers: [
                    BlocProvider(
                      create: (_) => getIt<UserVerifiedPropertiesCubit>(),
                    ),
                  ], child: const PropertyVerifications()),
                ),
              ),
              GoRoute(
                path: AppRoutePath.documentPage,
                pageBuilder: (context, state) {
                  return CustomPageTransition.slideFromRight(
                    child: MultiBlocProvider(
                        providers: [
                          BlocProvider(
                            create: (_) => getIt<DocumentCubit>(),
                          ),
                        ],
                        child: DocumentPage(
                            documentKey:
                                state.pathParameters['key'] as String)),
                  );
                },
              ),
            ]),
      ],
      errorBuilder: (context, state) => Scaffold(
        body: Center(
          child: Text(
            'Error: ${state.error}',
            style: context.text.bodyMedium,
          ),
        ),
      ),
    );
  }
}
