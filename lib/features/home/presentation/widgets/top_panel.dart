import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:neighbours/core/extensions/context_ext.dart';
import 'package:neighbours/core/router/app_routes.dart';
import 'package:neighbours/features/notification/presentation/cubits/notification_cubit.dart';
import '../../../../core/components/custom_button.dart';
import '../../../../core/components/default_circle_avatar.dart';
import '../../../../core/cubits/user/user_cubit.dart';
import '../cubits/home/home_cubit.dart';

class TopPanel extends StatelessWidget {
  const TopPanel({super.key});

  void _onProfileClick(BuildContext context) {
    final cubit = context.read<HomeCubit>();
    if (cubit.canOpenProfile()) {
      context.push(AppRoutePath.profile);
    } else {
      context.read<HomeCubit>()
        ..setIdle()
        ..goToUserInfoStep();
    }
  }

  void _onCommunitiesClick(BuildContext context) {
    final community =
        context.read<UserCubit>().state.user.communities.firstOrNull;
    if (community == null) {
      context.read<HomeCubit>().showNoActiveCommunities();
    } else {
      context.push(AppRouteBuilder.community(community.id), extra: community);
    }
  }

  @override
  Widget build(BuildContext context) {
    final hasUnreadNotifications = context.select<NotificationCubit, bool>(
        (cubit) => cubit.hasUnreadNotifications);
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        GestureDetector(
          onTap: () => _onProfileClick(context),
          child: BlocBuilder<UserCubit, UserState>(
            buildWhen: (prev, curr) =>
                prev.user.avatar != curr.user.avatar ||
                prev.user.firstName != curr.user.firstName,
            builder: (context, state) {
              return AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: hasUnreadNotifications
                        ? context.color.basicRed
                        : Colors.transparent,
                    width: 2,
                  ),
                ),
                child: DefaultCircleAvatar(
                  radius: 25,
                  id: state.user.id,
                  name: state.user.firstName,
                  url: state.user.avatar,
                  textStyle: context.text.bodyLarge,
                ),
              );
            },
          ),
        ),
        CustomButton(
          onPressed: () => _onCommunitiesClick(context),
          width: 40,
          height: 40,
          icon: Icon(
            Icons.people_outline_rounded,
            color: context.color.primary,
          ),
          style: BoxDecoration(
              color: context.color.secondary,
              shape: BoxShape.circle,
              border: BoxBorder.all(width: 2, color: context.color.primary)),
        )
      ],
    );
  }
}
