import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:neighbours/core/components/custom_button.dart';
import 'package:neighbours/core/components/custom_label.dart';
import 'package:neighbours/core/components/custom_svg.dart';
import 'package:neighbours/core/components/default_app_bar.dart';
import 'package:neighbours/core/components/default_loading_overlay.dart';
import 'package:neighbours/core/components/default_page_wrapper.dart';
import 'package:neighbours/core/components/primary_button.dart';
import 'package:neighbours/core/extensions/context_ext.dart';
import 'package:neighbours/core/components/reusable_text_field.dart';
import 'package:neighbours/core/state/api_state.dart';
import 'package:neighbours/features/property/presentation/cubits/resource_form/resource_form_cubit.dart';
import 'package:neighbours/features/property/presentation/cubits/resources/resources_cubit.dart';

import '../../../../core/components/bottom_sheet_dialog.dart';
import '../../../../core/components/custom_alert_dialog.dart';
import '../../../../core/components/custom_gap.dart';
import '../../../../core/components/custom_radio_button.dart';
import '../../../../core/components/image_picker_field.dart';
import '../../../../core/constants/assets.dart';
import '../../../home/presentation/widgets/select_field.dart';

class ResourceForm extends StatefulWidget {
  const ResourceForm({super.key});

  @override
  State<ResourceForm> createState() => _ResourceFormState();
}

class _ResourceFormState extends State<ResourceForm> {
  late TextEditingController _resourceName;

  @override
  void initState() {
    final state = context.read<ResourceFormCubit>().state;
    _resourceName = TextEditingController(text: state.name);
    super.initState();
  }

  @override
  void dispose() {
    _resourceName.dispose();
    super.dispose();
  }

  void _showCategoryBottomSheet(BuildContext context, String? selectedType) {
    showBaseBottomSheet<String>(
      backgroundColor: context.color.secondary,
      context: context,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Категория', style: context.text.bodyMedium),
          const VerticalGap(8),
          ...context.read<ResourceFormCubit>().typeLabels.map(
            (typeLabel) {
              final cubit = context.read<ResourceFormCubit>();
              final isActive = cubit.getLabel(selectedType ?? '') == typeLabel;
              return CustomRadioButton(
                value: typeLabel,
                title: typeLabel,
                isActive: isActive,
                inActiveColor: context.color.background,
                titleTextStyle: context.text.bodyLarge,
                onTap: (_) {
                  final apiValue = cubit.getApiTypeByLabel(typeLabel);
                  cubit.setCategory(apiValue);
                  Navigator.of(context).pop();
                },
              );
            },
          ).toList(),
        ],
      ),
    );
  }

  Future<void> _onDeleteClick(BuildContext context, int resourceId) async {
    final deleteConfirm = await showDialog<bool>(
      context: context,
      builder: (context) => CustomAlertDialog(
        title: 'Удалить ресурс?',
        content: 'Вы уверены, что хотите удалить выбранный ресурс?',
        confirmText: 'Да',
        isConfirmDestructive: true,
        onCancel: () => Navigator.pop(context, false),
        onConfirm: () => Navigator.pop(context, true),
      ),
    );

    if (deleteConfirm == true && context.mounted) {
      context.read<ResourcesCubit>().deleteResource(resourceId);
      context.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final resourceFormCubit = context.read<ResourceFormCubit>();
    final isNewResource = resourceFormCubit.isNewResource();
    final isCreating = context
        .select((ResourcesCubit cubit) => cubit.state.createState.isLoading);
    final isDeleting = context
        .select((ResourcesCubit cubit) => cubit.state.deleteState.isLoading);
    final isUpdating = context
        .select((ResourcesCubit cubit) => cubit.state.updateState.isLoading);

    return BlocListener<ResourcesCubit, ResourcesState>(
      listenWhen: (prev, curr) =>
          (prev.deleteState.isLoading && !curr.deleteState.isLoading) ||
          (prev.updateState.isLoading && !curr.updateState.isLoading) ||
          (prev.createState.isLoading && !curr.createState.isLoading),
      listener: (context, state) {
        if (state.hasError) {
          context.snackbar.error(context, state.error!);
        }  else if (state.updateState.isSuccess) {
          context.snackbar.success(context, 'Ресурс успешно обновлён');
        } else if (state.createState.isSuccess) {
          context.pop();
        }
      },
      child: Stack(
        children: [
          Scaffold(
            appBar: DefaultAppBar(
              showBackButton: true,
              title: isNewResource
                  ? 'Добавление ресурса'
                  : 'Редактирование ресурса',
              actions: [
                if (!isNewResource)
                  CustomButton(
                    onPressed: isDeleting
                        ? () {}
                        : () =>
                            _onDeleteClick(context, resourceFormCubit.state.id),
                    svgIcon: CustomSvg(
                        asset: Assets.icons.delete,
                        color: context.color.basicRed),
                  )
              ],
            ),
            body: DefaultPageWrapper(children: [
              const CustomLabel(
                text: 'Название',
                isRequired: true,
              ),
              const VerticalGap(4),
              BlocBuilder<ResourceFormCubit, ResourceFormState>(
                  buildWhen: (old, curr) =>
                      old.nameError != curr.nameError || old.name != curr.name,
                  builder: (context, state) {
                    return ReusableTextField(
                      controller: _resourceName,
                      hintText: 'Введите название ресурса',
                      errorText: state.nameError,
                      onChange: resourceFormCubit.updateName,
                    );
                  }),
              const VerticalGap(8),
              const CustomLabel(
                text: 'Фото',
              ),
              const VerticalGap(4),
              BlocBuilder<ResourceFormCubit, ResourceFormState>(
                builder: (context, state) {
                  return ImagePickerField(
                    isCircular: false,
                    photoUrl: state.photoUrl,
                    width: 120,
                    height: 100,
                    borderRadius: 8,
                    pickedImage: state.newPhotoFile,
                    onPickImage: () async {
                      await resourceFormCubit.pickImageFromGallery();
                    },
                    onRemoveImage: () {
                      resourceFormCubit.removeImage();
                    },
                  );
                },
              ),
              const VerticalGap(8),
              const CustomLabel(
                text: 'Категория',
                isRequired: true,
              ),
              const VerticalGap(4),
              BlocSelector<ResourceFormCubit, ResourceFormState, String>(
                selector: (state) => state.category,
                builder: (context, selectedType) {
                  return SelectField(
                      label: 'Категория',
                      value: context
                          .read<ResourceFormCubit>()
                          .getLabel(selectedType),
                      icon: Icons.keyboard_arrow_down_rounded,
                      onTap: () =>
                          _showCategoryBottomSheet(context, selectedType));
                },
              ),
              const Spacer(),
              BlocSelector<ResourceFormCubit, ResourceFormState, bool>(
                  selector: (state) => resourceFormCubit.isSubmitEnabled(),
                  builder: (context, isEnabled) {
                    return PrimaryButton(
                      text: isNewResource ? 'Добавить' : 'Изменить',
                      isEnabled: isEnabled && !isDeleting && !isUpdating,
                      onPressed: () async {
                        if (isNewResource) {
                          await context.read<ResourcesCubit>().createResource(
                                name: resourceFormCubit.state.name,
                                category: resourceFormCubit.state.category,
                                propertyId: resourceFormCubit.state.propertyId,
                                photo: resourceFormCubit.state.newPhotoFile,
                              );
                        } else {
                          final updatedResource = await context
                              .read<ResourcesCubit>()
                              .updateResource(
                                id: resourceFormCubit.state.id,
                                name: resourceFormCubit.state.name,
                                category: resourceFormCubit.state.category,
                                photo: resourceFormCubit.state.newPhotoFile,
                              );
                          if (updatedResource != null) {
                            resourceFormCubit
                                .resetOriginalResource(updatedResource);
                          }
                        }
                      },
                      isLoading: isCreating || isUpdating,
                    );
                  }),
              const VerticalGap(16),
            ]),
          ),
          if (isDeleting) const DefaultLoadingOverlay()
        ],
      ),
    );
  }
}
