import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:neighbours/core/components/custom_gap.dart';
import 'package:neighbours/core/components/custom_outlined_button.dart';
import 'package:neighbours/core/components/custom_svg.dart';
import 'package:neighbours/core/components/default_app_bar.dart';
import 'package:neighbours/core/components/default_loading_overlay.dart';
import 'package:neighbours/core/cubits/properties/properties_cubit.dart';
import 'package:neighbours/core/cubits/user/user_cubit.dart';
import 'package:neighbours/core/cubits/user_location/user_location_cubit.dart';
import 'package:neighbours/core/domain/entities/property/property_entity.dart';
import 'package:neighbours/core/extensions/context_ext.dart';
import 'package:neighbours/core/router/app_routes.dart';
import 'package:neighbours/core/state/api_state.dart';
import 'package:neighbours/core/themes/theme.dart';
import 'package:neighbours/features/property/presentation/cubits/resources/resources_cubit.dart';
import 'package:neighbours/features/property/presentation/widgets/property_resources.dart';
import '../../../../core/components/bottom_sheet_dialog.dart';
import '../../../../core/components/bottom_sheet_option.dart';
import '../../../../core/components/custom_alert_dialog.dart';
import '../../../../core/components/custom_button.dart';
import '../../../../core/components/shaped_cached_image.dart';
import '../../../../core/constants/assets.dart';
import '../../../../core/constants/default_constants.dart';
import '../../../../core/constants/ui_constants.dart';
import '../widgets/label_value_text.dart';

class PropertyDetails extends StatefulWidget {
  final int propertyId;

  const PropertyDetails({super.key, required this.propertyId});

  @override
  State<PropertyDetails> createState() => _PropertyDetailsState();
}

class _PropertyDetailsState extends State<PropertyDetails> {
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
                onClick: () {}),
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
            prev.verifyState.isLoading != curr.verifyState.isLoading,
        builder: (context, state) {
          final properties = state.properties;
          final PropertyEntity currentProperty = properties[widget.propertyId]!;
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
                          padding: const EdgeInsets.symmetric(
                            horizontal: UIConstants.defaultHorizontalPadding,
                            vertical: 12,
                          ),
                          child: CustomOutlinedButton(
                              onPressed: () async {
                                final userLocation = await context
                                    .read<UserLocationCubit>()
                                    .getPosition();
                                if (userLocation != null && context.mounted) {
                                  await context
                                      .read<PropertiesCubit>()
                                      .verifyProperty(
                                          propertyId: currentProperty.id,
                                          userLatitude: userLocation.latitude,
                                          userLongitude:
                                              userLocation.longitude);
                                }
                              },
                              text: 'Подтвердить'))
                      : null,
                  body: SingleChildScrollView(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: UIConstants.defaultHorizontalPadding),
                      child: Column(
                        children: [
                          const VerticalGap(8),
                          Container(
                            alignment: Alignment.centerLeft,
                            child: ShapedCachedImage(
                              radius: 32,
                              url: currentProperty.photo,
                              border: Border.all(
                                  width: 2,
                                  color: currentProperty.verificationStatus ==
                                          DefaultConstants.verified
                                      ? context.color.primary
                                      : CommonModeColors.orange),
                            ),
                          ),
                          const VerticalGap(16),
                          LabelValueText(
                              label: 'Тип',
                              value: DefaultConstants.propertyTypeOptions[
                                      currentProperty.category] ??
                                  'Неизвестно'),
                          const VerticalGap(8),
                          LabelValueText(
                            label: 'Состояние',
                            value:
                                currentProperty.buildVerificationStatusText(),
                            valueColor: currentProperty.verificationStatusColor(context),
                          ),
                          const VerticalGap(8),
                          LabelValueText(
                              label: 'Пользователь',
                              value: currentProperty.createdBy),
                          const VerticalGap(8),
                          Container(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              'Ресурсы',
                              style: context.text.titleSmall,
                            ),
                          ),
                          const VerticalGap(8),
                          PropertyResources(
                            propertyId: widget.propertyId,
                            isUserProperty: isUserProperty,
                          ),
                          const VerticalGap(16),
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
