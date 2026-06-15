import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:neighbours/core/components/custom_gap.dart';
import 'package:neighbours/core/components/custom_swtich.dart';
import 'package:neighbours/core/components/default_app_bar.dart';
import 'package:neighbours/core/components/default_loading_overlay.dart';
import 'package:neighbours/core/constants/assets.dart';
import 'package:neighbours/core/cubits/theme/theme_cubit.dart';
import 'package:neighbours/core/cubits/user/user_cubit.dart';
import 'package:neighbours/core/extensions/context_ext.dart';
import 'package:neighbours/core/router/app_routes.dart';
import 'package:neighbours/core/state/api_state.dart';
import 'package:neighbours/features/event/presentation/widgets/default_divider.dart';
import 'package:neighbours/features/profile/presentation/widgets/menu_list_item.dart';
import '../../../../core/components/custom_alert_dialog.dart';
import '../../../../core/constants/ui_constants.dart';
import '../../../../core/services/snackbar_service.dart';

class Settings extends StatelessWidget {
  const Settings({super.key});

  void _onDeleteClick(BuildContext context) async {
    final deleteConfirm = await showDialog<bool>(
      context: context,
      builder: (context) => CustomAlertDialog(
        title: 'Вы уверены?',
        content:
            'Ваш профиль будет удален через 30 дней.\nВы можете отказаться от решения в течении 30 дней.',
        confirmText: 'Да',
        isConfirmDestructive: true,
        onCancel: () => Navigator.pop(context, false),
        onConfirm: () => Navigator.pop(context, true),
      ),
    );

    if (deleteConfirm == true && context.mounted) {
      context.read<UserCubit>().requestProfileDeletion();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme =
        context.select<ThemeCubit, bool>((cubit) => cubit.state.isDark);
    final deletionScheduledAt = context.select<UserCubit, DateTime?>(
        (cubit) => cubit.state.user.deletionScheduledAt);
    final dateFormat = DateFormat("dd.MM.yyyy");
    return BlocConsumer<UserCubit, UserState>(
      listenWhen: (prev, curr) =>
          prev.requestProfileDeletion != curr.requestProfileDeletion,
      listener: (context, state) {
        if (state.requestProfileDeletion.isSuccess) {
          final code = state.deletionRequestCode;
          final currentLocation = GoRouter.of(context).state.fullPath;

          if (currentLocation != null &&
              !currentLocation.contains(AppRoutePath.deleteSmsCode)) {
            context.snackbar.info(context, 'Код для тестирования: $code',
                position: SnackBarPosition.top);
            if (context.mounted) context.pushNamed(AppRoutePath.deleteSmsCode);
          }
        }
        if (state.restoreProfile.isSuccess) {
          context.snackbar.success(context, 'Ваш профиль воссановлен');
        }
        if (state.requestProfileDeletion.isFailure) {
          context.snackbar.show(context, state.requestProfileDeletion.error!);
        }
      },
      builder: (context, state) {
        final isLoading = state.restoreProfile.isLoading ||
            state.requestProfileDeletion.isLoading;
        return Stack(
          children: [
            Scaffold(
              appBar: const DefaultAppBar(
                showBackButton: true,
                title: 'Настройки',
              ),
              body: SingleChildScrollView(
                child: Column(
                  children: [
                    const VerticalGap(16),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: UIConstants.defaultHorizontalPadding),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "Тема",
                            style: context.text.bodyLarge,
                          ),
                          CustomSwitch(
                              value: theme,
                              width: 40,
                              height: 24,
                              backgroundOnColor: context.color.primary,
                              backgroundOffColor: context.color.secondary,
                              thumbColor: Colors.white,
                              thumbBorder: Border.all(
                                  width: 1, color: context.color.tertiary),
                              thumbSize: 20,
                              onToggle: (value) => context
                                  .read<ThemeCubit>()
                                  .setCurrentTheme(value))
                        ],
                      ),
                    ),
                    const VerticalGap(16),
                    const DefaultDivider(),
                    MenuListItem(
                      text: deletionScheduledAt != null
                          ? 'Восстановить до ${dateFormat.format(deletionScheduledAt)}'
                          : 'Удалить профиль',
                      onTap: () => deletionScheduledAt != null
                          ? context.read<UserCubit>().restoreProfile()
                          : _onDeleteClick(context),
                      textColor: deletionScheduledAt != null
                          ? context.color.primary
                          : context.color.basicRed,
                      iconColor: deletionScheduledAt != null
                          ? context.color.primary
                          : context.color.basicRed,
                      iconPath: deletionScheduledAt != null
                          ? Assets.icons.reset
                          : Assets.icons.delete,
                      showArrow: true,
                    )
                  ],
                ),
              ),
            ),
            if (isLoading) const DefaultLoadingOverlay()
          ],
        );
      },
    );
  }
}
