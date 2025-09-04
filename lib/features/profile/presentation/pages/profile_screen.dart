import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:neighbours/core/components/custom_button.dart';
import 'package:neighbours/core/components/custom_gap.dart';
import 'package:neighbours/core/components/default_app_bar.dart';
import 'package:neighbours/core/components/default_circle_avatar.dart';
import 'package:neighbours/core/components/default_page_wrapper.dart';
import 'package:neighbours/core/constants/default_constants.dart';
import 'package:neighbours/core/cubits/events/events_cubit.dart';
import 'package:neighbours/core/cubits/properties/properties_cubit.dart';
import 'package:neighbours/core/cubits/user/user_cubit.dart';
import 'package:neighbours/core/domain/entities/user/user_entity.dart';
import 'package:neighbours/core/extensions/context_ext.dart';
import 'package:neighbours/core/extensions/full_name_ext.dart';
import 'package:neighbours/features/notification/presentation/cubits/notification_cubit.dart';
import 'package:neighbours/features/profile/presentation/cubits/profile/profile_cubit.dart';

import '../../../../core/components/custom_alert_dialog.dart';
import '../../../../core/router/app_routes.dart';
import '../widgets/menu_list_item.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  Future<void> _onLogoutClick(BuildContext context) async {
    final logoutConfirm = await showDialog<bool>(
      context: context,
      builder: (context) => CustomAlertDialog(
        title: 'Выход из аккаунта',
        content: 'Вы уверены, что хотите выйти из аккаунта?',
        confirmText: 'Выйти',
        isConfirmDestructive: true,
        onCancel: () => Navigator.pop(context, false),
        onConfirm: () => Navigator.pop(context, true),
      ),
    );

    if (logoutConfirm == true && context.mounted) {
      context.read<ProfileCubit>().logout();
    }
  }

  @override
  Widget build(BuildContext context) {
    final user =
        context.select<UserCubit, UserEntity>((cubit) => cubit.state.user);
    final property = context.read<PropertiesCubit>().getUserProperty(user.id);
    final community = user.communities.firstOrNull;
    final hasUnreadNotifications = context.select<NotificationCubit, bool>(
        (cubit) => cubit.state.unreadCount > 0);
    return Scaffold(
      appBar: DefaultAppBar(
        showBackButton: true,
        centerTitle: true,
        title: 'Профиль',
        actions: [
          CustomButton(
            onPressed: () => context.pushNamed(AppRoutePath.editProfile),
            icon: Icon(
              Icons.edit,
              color: context.color.secondaryText,
            ),
          )
        ],
      ),
      body: BlocListener<ProfileCubit, ProfileState>(
        listener: (context, state) {
          state.maybeWhen(
            error: (message) => context.snackbar.error(context, message),
            logoutSuccess: () {
              context.read<PropertiesCubit>().onLogout();
              context.read<EventsCubit>().onLogout();
              context.read<NotificationCubit>().onLogout();
              WidgetsBinding.instance.addPostFrameCallback((_) {
                context.go(AppRoutePath.authWelcome);
              });
            },
            orElse: () {},
          );
        },
        child: DefaultPageWrapper(
          padding: EdgeInsets.zero,
          children: [
            const VerticalGap(24),
            Center(
              child: Column(
                children: [
                  DefaultCircleAvatar(
                      name: user.firstName,
                      radius: 40,
                      url: user.avatar,
                      id: user.id,
                      textStyle: context.text.bodyLarge),
                  const VerticalGap(16),
                  Text(
                    user.fullName,
                    style: context.text.titleSmall,
                  ),
                ],
              ),
            ),
            const VerticalGap(16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Divider(color: context.color.secondaryText, height: 1),
            ),
            if (property != null)
              MenuListItem(
                text: 'Мой объект',
                onTap: () =>
                    context.push(AppRouteBuilder.propertyDetails(property.id)),
                showArrow: true,
              ),
            if (community != null)
              MenuListItem(
                text: 'Мое сообщество',
                onTap: () =>
                    context.push(AppRoutePath.communityInfo, extra: community),
                showArrow: true,
              ),
            MenuListItem(
              text: 'Мои мероприятия и оповещения',
              onTap: () => context.pushNamed(AppRoutePath.myEvents),
            ),
            MenuListItem(
              text: 'Мои подтверждения',
              onTap: () =>
                  context.pushNamed(AppRoutePath.propertyVerifications),
            ),
            MenuListItem(
              icon: Icons.notifications_none_rounded,
              text: 'Уведомления',
              showBadge: hasUnreadNotifications,
              iconColor: context.color.primary,
              onTap: () => context.pushNamed(AppRoutePath.notifications),
            ),
            MenuListItem(
              icon: Icons.currency_ruble,
              text: 'Помощь проекту',
              iconColor: context.color.primary,
              onTap: () {},
            ),
            MenuListItem(
              icon: Icons.settings_outlined,
              text: 'Настройки приложения',
              iconColor: context.color.primary,
              onTap: () => context.pushNamed(AppRoutePath.settingsPage),
            ),
            MenuListItem(
              icon: Icons.chat_bubble_outline,
              text: 'Справочный центр',
              iconColor: context.color.primary,
              onTap: () {},
            ),
            MenuListItem(
              icon: Icons.help_outline,
              text: 'Часто задаваемые вопросы',
              iconColor: context.color.primary,
              onTap: () {},
            ),
            MenuListItem(
              icon: Icons.info_outline,
              text: 'О приложении',
              iconColor: context.color.primary,
              onTap: () {},
            ),
            MenuListItem(
              icon: Icons.description_outlined,
              text: 'Лицензионное соглашение',
              iconColor: context.color.primary,
              onTap: () => context
                  .push(AppRouteBuilder.documentPage(DefaultConstants.license)),
            ),
            MenuListItem(
              icon: Icons.verified_user_outlined,
              text: 'Политика конфиденциальности',
              iconColor: context.color.primary,
              onTap: () => context
                  .push(AppRouteBuilder.documentPage(DefaultConstants.privacy)),
            ),
            MenuListItem(
              icon: Icons.logout_rounded,
              text: 'Выйти',
              iconColor: context.color.basicRed,
              textColor: context.color.basicRed,
              onTap: () async {
                await _onLogoutClick(context);
              },
            ),
          ],
        ),
      ),
    );
  }
}
