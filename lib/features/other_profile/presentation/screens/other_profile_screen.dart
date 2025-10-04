import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:neighbours/core/components/custom_gap.dart';
import 'package:neighbours/core/components/custom_outlined_button.dart';
import 'package:neighbours/core/components/default_app_bar.dart';
import 'package:neighbours/core/components/default_loading_overlay.dart';
import 'package:neighbours/core/components/default_page_wrapper.dart';
import 'package:neighbours/core/components/shaped_cached_image.dart';
import 'package:neighbours/core/constants/default_constants.dart';
import 'package:neighbours/core/cubits/user/user_cubit.dart';
import 'package:neighbours/core/domain/entities/user/user_entity.dart';
import 'package:neighbours/core/extensions/context_ext.dart';
import 'package:neighbours/core/extensions/full_name_ext.dart';
import 'package:neighbours/core/router/app_routes.dart';
import 'package:neighbours/core/state/api_state.dart';
import 'package:neighbours/features/community/presentation/widgets/light_community_item.dart';
import 'package:neighbours/features/other_profile/presentation/cubits/other_profile/other_profile_cubit.dart';
import 'package:neighbours/features/other_profile/presentation/cubits/other_properties/other_properties_cubit.dart';
import 'package:neighbours/features/other_profile/presentation/services/other_profile_share_service.dart';
import 'package:neighbours/features/property/presentation/widgets/light_property_item.dart';

import '../../../../core/components/bottom_sheet_dialog.dart';
import '../../../../core/components/bottom_sheet_option.dart';
import '../../../../core/components/custom_button.dart';
import '../../../../core/components/custom_svg.dart';
import '../../../../core/constants/assets.dart';

class OtherProfileScreen extends StatefulWidget {
  final int userId;

  const OtherProfileScreen({super.key, required this.userId});

  @override
  State<OtherProfileScreen> createState() => _OtherProfileScreenState();
}

class _OtherProfileScreenState extends State<OtherProfileScreen> {
  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<OtherProfileCubit>().fetchUser(widget.userId);
    });

    super.initState();
  }

  void _onOptionsClick(BuildContext context, int userId, bool isMyProfile) {
    showBaseBottomSheet(
        context: context,
        isDismissible: true,
        enableDrag: true,
        backgroundColor: context.color.secondary,
        child: Column(
          children: [
            if (isMyProfile)
              BottomSheetOption(
                  text: 'Редактировать',
                  iconPath: Assets.icons.edit,
                  onClick: () => context.pushNamed(
                        AppRoutePath.editProfile,
                      )),
            BottomSheetOption(
                text: 'Поделиться',
                iconPath: Assets.icons.share,
                onClick: () {
                  context.pop();
                  OtherProfileShareService.shareEvent(userId);
                }),
          ],
        ));
  }

  String _formatDate(DateTime? date) {
    if (date == null) return '';
    return '${date.day.toString().padLeft(2, '0')}.${date.month.toString().padLeft(2, '0')}.${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    final me =
        context.select<UserCubit, UserEntity>((cubit) => cubit.state.user);
    return BlocConsumer<OtherProfileCubit, OtherProfileState>(
      listener: (context, state) {
        state.fetchUserState.handleApiState(
          onSuccess: () {
            context
                .read<OtherPropertiesCubit>()
                .fetchUserProperties(widget.userId);
          },
          onError: (error) => context.snackbar.error(
            context,
            error,
          ),
        );
      },
      buildWhen: (prev, curr) =>
          prev.fetchUserState != curr.fetchUserState || prev.user != curr.user,
      builder: (context, state) {
        if (state.user == null) {
          if (!state.fetchUserState.isLoading &&
              state.fetchUserState.isFailure) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (context.mounted) {
                context.replace(AppRoutePath.notFound,
                    extra: DefaultConstants.userNotFoundText);
              }
            });
          }
          return const Scaffold(
            body: DefaultLoadingOverlay(),
          );
        }
        final otherUser = state.user!;
        final sameUser = otherUser.id == me.id;
        return Scaffold(
          appBar: DefaultAppBar(
            showBackButton: true,
            actions: [
              CustomButton(
                onPressed: () =>
                    _onOptionsClick(context, otherUser.id, sameUser),
                svgIcon: CustomSvg(
                    asset: Assets.icons.option,
                    color: context.color.secondaryText),
              )
            ],
          ),
          body: DefaultPageWrapper(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              ShapedCachedImage(
                radius: 48,
                url: sameUser ? me.avatar : otherUser.avatar,
                border: Border.all(width: 2, color: context.color.primary),
              ),
              const VerticalGap(16),
              Text(
                sameUser ? me.fullName : otherUser.fullName,
                style: context.text.titleSmall,
              ),
              const VerticalGap(8),
              RichText(
                text: TextSpan(
                  children: [
                    TextSpan(
                      text: "В ",
                      style: context.text.bodyLarge,
                    ),
                    TextSpan(
                      text: "8024",
                      style: context.text.bodyLarge.copyWith(
                        fontWeight: FontWeight.bold,
                        color: context.color.primary,
                      ),
                    ),
                    TextSpan(
                      text: " с ${_formatDate(otherUser.createdAt)}",
                      style: context.text.bodyLarge,
                    ),
                  ],
                ),
              ),
              const VerticalGap(24),
              if (otherUser.communities.isNotEmpty) ...[
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    sameUser ? "Ваши сообщества" : 'Ваши общие сообщетсва',
                    style: context.text.bodyMedium.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                const VerticalGap(8),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: otherUser.communities.map((community) {
                    return LightCommunityItem(community: community);
                  }).toList(),
                ),
                const VerticalGap(16),
              ],
              BlocBuilder<OtherPropertiesCubit, OtherPropertiesState>(
                builder: (context, propertiesState) {
                  if (propertiesState.fetchPropertiesState.isLoading) {
                    return DefaultLoadingOverlay();
                  }
                  if (propertiesState.properties.isEmpty) {
                    return const SizedBox.shrink();
                  }

                  return Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          'Объекты недвижимости',
                          style: context.text.bodyMedium.copyWith(
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      const VerticalGap(8),
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        children: propertiesState.properties.map((property) {
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 8),
                            child: LightPropertyItem(property: property),
                          );
                        }).toList(),
                      ),
                      const VerticalGap(24),
                    ],
                  );
                },
              ),
              const Spacer(),
              if (!sameUser)
                CustomOutlinedButton(
                    onPressed: () => context.push(
                            AppRouteBuilder.privateChatPage(otherUser.id),
                            extra: {
                              "interlocutorName": otherUser.fullName,
                              "receiverId": otherUser.id,
                              "interlocutorAvatarUrl": otherUser.avatar,
                              "interlocutorId": otherUser.id
                            }),
                    text: "Написать"),
              const VerticalGap(16)
            ],
          ),
        );
      },
    );
  }
}
