import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:neighbours/core/components/custom_gap.dart';
import 'package:neighbours/core/components/custom_outlined_button.dart';
import 'package:neighbours/core/components/custom_svg.dart';
import 'package:neighbours/core/components/default_app_bar.dart';
import 'package:neighbours/core/components/default_loading_overlay.dart';
import 'package:neighbours/core/cubits/user/user_cubit.dart';
import 'package:neighbours/core/extensions/context_ext.dart';
import 'package:neighbours/core/router/app_routes.dart';
import 'package:neighbours/core/state/api_state.dart';
import 'package:neighbours/core/themes/theme.dart';
import 'package:neighbours/features/property/domain/entities/property/property_entity.dart';
import 'package:neighbours/features/property/presentation/cubits/properties/properties_cubit.dart';
import 'package:neighbours/features/property/presentation/cubits/resources/resources_cubit.dart';
import 'package:neighbours/features/property/presentation/services/property_share_service.dart';
import 'package:neighbours/features/property/presentation/widgets/property_confirmation_banner.dart';
import 'package:neighbours/features/property/presentation/widgets/property_info_row.dart';
import 'package:neighbours/features/property/presentation/widgets/property_resources.dart';
import 'package:neighbours/features/property/presentation/widgets/verify_property_dialog.dart';
import '../../../../core/components/bottom_sheet_dialog.dart';
import '../../../../core/components/bottom_sheet_option.dart';
import '../../../../core/components/custom_alert_dialog.dart';
import '../../../../core/components/custom_button.dart';
import '../../../../core/components/shaped_cached_image.dart';
import '../../../../core/constants/assets.dart';
import '../../../../core/constants/default_constants.dart';
import '../../../../core/constants/ui_constants.dart';

class PropertyDetails extends StatefulWidget {
  final int propertyId;

  const PropertyDetails({super.key, required this.propertyId});

  @override
  State<PropertyDetails> createState() => _PropertyDetailsState();
}

class _PropertyDetailsState extends State<PropertyDetails> {
  String _formatDate(DateTime date) {
    final months = [
      'января',
      'февраля',
      'марта',
      'апреля',
      'мая',
      'июня',
      'июля',
      'августа',
      'сентября',
      'октября',
      'ноября',
      'декабря'
    ];

    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }

  void _onOptionsClick(
      BuildContext context, PropertyEntity property, bool isUserProperty) {
    showBaseBottomSheet(
        context: context,
        isDismissible: true,
        enableDrag: true,
        backgroundColor: context.color.secondary,
        child: Column(
          children: [
            if (isUserProperty)
              BottomSheetOption(
                  text: 'Редактировать',
                  iconPath: Assets.icons.edit,
                  onClick: () => context.push(
                      AppRouteBuilder.propertyEdit(property.id),
                      extra: property)),
            BottomSheetOption(
                text: 'Поделиться',
                iconPath: Assets.icons.share,
                onClick: () {
                  context.pop();
                  PropertyShareService.shareProperty(property.id);
                }),
            if (isUserProperty)
              BottomSheetOption(
                text: 'Удалить',
                iconPath: Assets.icons.delete,
                onClick: () => _onDeleteClick(context),
                isDelete: true,
              ),
          ],
        ));
  }

  Future<void> _onDeleteClick(BuildContext context) async {
    final deleteConfirm = await showDialog<bool>(
      context: context,
      builder: (context) => CustomAlertDialog(
        title: 'Удалить объект?',
        content: 'Вы уверены, что хотите удалить объект недвижимости?',
        confirmText: 'Да',
        isConfirmDestructive: true,
        onCancel: () => context.pop(false),
        onConfirm: () => context.pop(true),
      ),
    );

    if (deleteConfirm != true || !context.mounted) return;

    context.read<PropertiesCubit>().deleteProperty(widget.propertyId);
    context.pop();
  }

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<PropertiesCubit>().getPropertyById(widget.propertyId);
      context
          .read<ResourcesCubit>()
          .fetchResourcesByPropertyId(widget.propertyId);
    });

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final userId = context.read<UserCubit>().state.user.id;
    final isDeleting = context.select<PropertiesCubit, bool>(
        (cubit) => cubit.state.deleteState.isLoading);
    final isUpdating = context.select<PropertiesCubit, bool>(
        (cubit) => cubit.state.updateState.isLoading);
    final isVerifying = context.select<PropertiesCubit, bool>(
        (cubit) => cubit.state.verifyState.isLoading);

    void _onVerifyClick() {
      VerifyPropertyDialog.showDialog(context, widget.propertyId);
    }

    return BlocConsumer<PropertiesCubit, PropertiesState>(
        listener: (context, state) {
          state.deleteState.handleApiState(
              onSuccess: () {
                context.snackbar.success(
                  context,
                  'Объект недвижимости удален!',
                );
                context.go(AppRoutePath.home);
              },
              onError: (error) => context.snackbar.error(
                    context,
                    error,
                  ));
          state.verifyState.handleApiState(
              onSuccess: () {
                context.snackbar.success(
                  context,
                  'Объект недвижимости успешно подтвержден!',
                );
              },
              onError: (error) => context.snackbar.error(
                    context,
                    error,
                  ));
        },
        buildWhen: (prev, curr) =>
            prev.updateState.isLoading != curr.updateState.isLoading ||
            prev.verifyState.isLoading != curr.verifyState.isLoading ||
            prev.fetchState.isLoading != curr.fetchState.isLoading,
        builder: (context, state) {
          final currentProperty = state.properties[widget.propertyId];
          if (currentProperty == null) {
            if (!state.deleteState.isLoading && !state.deleteState.isSuccess) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                if (context.mounted) {
                  context.replace(AppRoutePath.notFound,
                      extra: DefaultConstants.propertyDeletedText);
                }
              });
            }
            return const Scaffold(
              body: DefaultLoadingOverlay(),
            );
          }
          final isUserProperty = currentProperty.createdById == userId;
          return Stack(
            children: [
              Scaffold(
                  appBar: DefaultAppBar(
                    showBackButton: true,
                    title: currentProperty.name,
                    actions: [
                      CustomButton(
                        onPressed: () => _onOptionsClick(
                            context, currentProperty, isUserProperty),
                        svgIcon: CustomSvg(
                            asset: Assets.icons.option,
                            color: context.color.secondaryText),
                      )
                    ],
                  ),
                  bottomNavigationBar: currentProperty.canVerify(userId)
                      ? Padding(
                          padding: EdgeInsets.symmetric(
                            horizontal: UIConstants.defaultHorizontalPadding,
                            vertical: 12,
                          ),
                          child: CustomOutlinedButton(
                              text: 'Подтвердить', onPressed: _onVerifyClick),
                        )
                      : null,
                  body: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          context.color.secondary,
                          context.color.secondary.withValues(alpha: .95),
                          context.color.secondary.withValues(alpha: .1),
                        ],
                      ),
                    ),
                    child: SingleChildScrollView(
                      child: Column(
                        children: [
                          // Информационный баннер
                          if (!currentProperty.isVerified &&
                              currentProperty.createdById == userId &&
                              currentProperty.confirmationCode != null)
                            PropertyConfirmationBanner(
                              confirmationCode:
                                  currentProperty.confirmationCode!,
                            ),

                          // Hero секция с фото объекта
                          Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: UIConstants.defaultHorizontalPadding,
                            ),
                            child: Container(
                              width: double.infinity,
                              margin:
                                  const EdgeInsets.only(bottom: 24, top: 24),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                  colors: currentProperty.isVerified
                                      ? [
                                          context.color.primary
                                              .withValues(alpha: .1),
                                          context.color.primary
                                              .withValues(alpha: 0.05),
                                        ]
                                      : [
                                          CommonModeColors.orange
                                              .withValues(alpha: 0.1),
                                          CommonModeColors.orange
                                              .withValues(alpha: 0.05),
                                        ],
                                ),
                                borderRadius: BorderRadius.circular(24),
                                boxShadow: [
                                  BoxShadow(
                                    color: context.color.tertiary
                                        .withValues(alpha: .1),
                                    blurRadius: 20,
                                    offset: const Offset(0, 8),
                                  ),
                                ],
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(24),
                                child: Column(
                                  children: [
                                    // Фото объекта с красивой рамкой
                                    ShapedCachedImage(
                                      radius: 24,
                                      url: currentProperty.photo,
                                      width: 120,
                                      height: 120,
                                      border: Border.all(
                                        width: 3,
                                        color: currentProperty.isVerified
                                            ? context.color.primary
                                            : CommonModeColors.orange,
                                      ),
                                    ),
                                    const VerticalGap(8),

                                    // Название объекта
                                    Text(
                                      currentProperty.name,
                                      style: context.text.titleSmall.copyWith(
                                        fontWeight: FontWeight.w700,
                                        color: context.color.primaryText,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                    const VerticalGap(16),

                                    // Статус верификации
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 16,
                                        vertical: 8,
                                      ),
                                      decoration: BoxDecoration(
                                        color: currentProperty.isVerified
                                            ? context.color.primary
                                                .withValues(alpha: .1)
                                            : CommonModeColors.orange
                                                .withValues(alpha: .1),
                                        borderRadius: BorderRadius.circular(20),
                                        border: Border.all(
                                          color: currentProperty.isVerified
                                              ? context.color.primary
                                              : CommonModeColors.orange,
                                          width: 1,
                                        ),
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Icon(
                                            currentProperty.isVerified
                                                ? Icons.verified_rounded
                                                : Icons.pending_rounded,
                                            size: 16,
                                            color: currentProperty.isVerified
                                                ? context.color.primary
                                                : CommonModeColors.orange,
                                          ),
                                          const HorizontalGap(6),
                                          Text(
                                            currentProperty
                                                .buildVerificationStatusText(),
                                            style:
                                                context.text.bodySmall.copyWith(
                                              color: currentProperty.isVerified
                                                  ? context.color.primary
                                                  : CommonModeColors.orange,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),

                          // Карточка с информацией об объекте
                          Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: UIConstants.defaultHorizontalPadding,
                            ),
                            child: Container(
                              width: double.infinity,
                              margin: const EdgeInsets.only(bottom: 24),
                              padding: const EdgeInsets.all(20),
                              decoration: BoxDecoration(
                                color: context.color.secondary,
                                borderRadius: BorderRadius.circular(20),
                                boxShadow: [
                                  BoxShadow(
                                    color: context.color.tertiary
                                        .withValues(alpha: .08),
                                    blurRadius: 20,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                                border: Border.all(
                                  color: context.color.tertiary
                                      .withValues(alpha: .1),
                                  width: 1,
                                ),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Icon(
                                        Icons.info_outline_rounded,
                                        color: context.color.primary,
                                        size: 20,
                                      ),
                                      const HorizontalGap(8),
                                      Text(
                                        'Информация об объекте',
                                        style: context.text.titleSmall.copyWith(
                                          fontWeight: FontWeight.w600,
                                          color: context.color.primaryText,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const VerticalGap(20),
                                  PropertyInfoRow(
                                    label: 'Тип объекта',
                                    value: DefaultConstants.propertyTypeOptions[
                                            currentProperty.category] ??
                                        'Неизвестно',
                                    icon: Icons.home_work_outlined,
                                  ),
                                  const VerticalGap(16),
                                  PropertyInfoRow(
                                    label: 'Создал объект',
                                    value: currentProperty.createdBy,
                                    icon: Icons.person_outline_rounded,
                                    onClick: () => context.push(
                                        AppRouteBuilder.otherProfile(
                                            currentProperty.createdById)),
                                  ),
                                  const VerticalGap(16),
                                  PropertyInfoRow(
                                    label: 'Дата создания',
                                    value:
                                        _formatDate(currentProperty.createdAt),
                                    icon: Icons.calendar_today_outlined,
                                  ),
                                ],
                              ),
                            ),
                          ),

                          // Секция ресурсов
                          Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: UIConstants.defaultHorizontalPadding,
                            ),
                            child: Container(
                              width: double.infinity,
                              margin: const EdgeInsets.only(bottom: 24),
                              padding: const EdgeInsets.all(20),
                              decoration: BoxDecoration(
                                color: context.color.secondary,
                                borderRadius: BorderRadius.circular(20),
                                boxShadow: [
                                  BoxShadow(
                                    color: context.color.tertiary
                                        .withValues(alpha: .08),
                                    blurRadius: 20,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                                border: Border.all(
                                  color: context.color.tertiary
                                      .withValues(alpha: .1),
                                  width: 1,
                                ),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Icon(
                                        Icons.inventory_2_outlined,
                                        color: context.color.primary,
                                        size: 20,
                                      ),
                                      const HorizontalGap(8),
                                      Text(
                                        'Ресурсы объекта',
                                        style: context.text.titleSmall.copyWith(
                                          fontWeight: FontWeight.w600,
                                          color: context.color.primaryText,
                                        ),
                                      ),
                                    ],
                                  ),
                                  PropertyResources(
                                    propertyId: widget.propertyId,
                                    isUserProperty: isUserProperty,
                                  ),
                                ],
                              ),
                            ),
                          ),

                          const VerticalGap(24),
                        ],
                      ),
                    ),
                  )),
              if (isDeleting || isUpdating || isVerifying)
                const DefaultLoadingOverlay()
            ],
          );
        });
  }
}
