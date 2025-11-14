import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:neighbours/core/components/custom_gap.dart';
import 'package:neighbours/core/cubits/user_location/user_location_cubit.dart';
import 'package:neighbours/core/extensions/context_ext.dart';
import 'package:neighbours/core/components/custom_label.dart';
import 'package:neighbours/core/services/snackbar_service.dart';
import 'package:neighbours/core/state/api_state.dart';
import 'package:neighbours/features/home/presentation/widgets/set_coordinates_button.dart';
import 'package:neighbours/features/property/presentation/cubits/properties/properties_cubit.dart';
import 'package:neighbours/features/property/presentation/cubits/property_form/property_form_cubit.dart';
import '../../../../core/components/category_select_field.dart';
import '../../../../core/components/image_picker_field.dart';
import '../../../../core/components/primary_button.dart';
import '../../../../core/components/reusable_text_field.dart';

class AddPropertyDialog extends StatefulWidget {
  final Function() onSuccess;
  final VoidCallback onSetCoordinatesClick;
  final bool isFirstProperty;

  const AddPropertyDialog(
      {super.key,
      required this.onSetCoordinatesClick,
      required this.onSuccess,
      required this.isFirstProperty});

  @override
  State<AddPropertyDialog> createState() => _AddPropertyDialogState();
}

class _AddPropertyDialogState extends State<AddPropertyDialog> {
  final _nameController = TextEditingController();

  @override
  void initState() {
    super.initState();

    final cubit = context.read<PropertyFormCubit>();
    _nameController.text = cubit.state.name;
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isUserLocationLoading = context
        .select<UserLocationCubit, bool>((cubit) => cubit.state.isLoading);
    final isCreating = context.select<PropertiesCubit, bool>(
        (cubit) => cubit.state.createState.isLoading);
    return BlocListener<PropertiesCubit, PropertiesState>(
      listener: (context, state) {
        if (state.createState.isFailure) {
          context.snackbar.error(context, state.createState.error!,
              position: SnackBarPosition.top);
        }
      },
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const CustomLabel(text: 'Название', isRequired: true),
            const VerticalGap(4),
            BlocBuilder<PropertyFormCubit, PropertyFormState>(
                buildWhen: (old, curr) =>
                    old.nameError != curr.nameError || old.name != curr.name,
                builder: (context, state) {
                  return ReusableTextField(
                    controller: _nameController,
                    hintText: 'Введите название',
                    onChange: (value) =>
                        context.read<PropertyFormCubit>().setName(value),
                    errorText: state.nameError,
                  );
                }),
            const VerticalGap(8),
            BlocSelector<PropertyFormCubit, PropertyFormState, String?>(
              selector: (state) => state.category,
              builder: (context, selectedType) {
                final cubit = context.read<PropertyFormCubit>();
                return CategorySelectField<String>(
                  label: 'Категория',
                  selectedValue: selectedType,
                  items: cubit.typeLabels,
                  itemLabel: (label) => label,
                  onChanged: (label) {
                    final apiValue = cubit.getApiTypeByLabel(label);
                    cubit.setCategory(apiValue);
                  },
                  isSelected: (label, selectedValue) =>
                      cubit.getApiTypeByLabel(label) == selectedValue,
                );
              },
            ),
            const VerticalGap(8),
            const CustomLabel(
                text: 'Выберите точку на карте', isRequired: true),
            const VerticalGap(4),
            BlocBuilder<PropertyFormCubit, PropertyFormState>(
              buildWhen: (prev, curr) =>
                  prev.latitude != curr.latitude ||
                  prev.longitude != curr.longitude,
              builder: (context, state) {
                final coords = state.longitude != null && state.latitude != null
                    ? '${state.latitude}, ${state.longitude}'
                    : null;
                return SetCoordinatesButton(
                  text: coords,
                  onClear: () => context.read<PropertyFormCubit>().clearCoordinates(),
                  onClick: widget.onSetCoordinatesClick,
                );
              },
            ),
            const VerticalGap(8),
            const CustomLabel(
              text: 'Фото',
              isRequired: true,
            ),
            const VerticalGap(4),
            BlocBuilder<PropertyFormCubit, PropertyFormState>(
              buildWhen: (prev, curr) => prev.pickedPhoto != curr.pickedPhoto,
              builder: (context, state) {
                return ImagePickerField(
                  pickedImage: state.pickedPhoto,
                  onPickImage: () async {
                    await context
                        .read<PropertyFormCubit>()
                        .pickImage(ImageSource.gallery);
                  },
                  onRemoveImage: () {
                    context.read<PropertyFormCubit>().removeImage();
                  },
                );
              },
            ),
            const VerticalGap(24),
            BlocBuilder<PropertyFormCubit, PropertyFormState>(
              builder: (context, state) {
                return PrimaryButton(
                  text: isCreating || isUserLocationLoading
                      ? 'Ожидайте'
                      : 'Добавить',
                  isEnabled:
                      context.read<PropertyFormCubit>().isSubmitEnabled(),
                  isLoading: isCreating || isUserLocationLoading,
                  onPressed: () async {
                    final userLocation =
                        await context.read<UserLocationCubit>().getPosition();
                    if (userLocation == null) return;
                    if (!context.mounted) return;

                    final property = await context
                        .read<PropertiesCubit>()
                        .addProperty(
                            isFirstProperty: widget.isFirstProperty,
                            name: state.name,
                            selectedType: state.category,
                            userLongitude: userLocation.longitude,
                            userLatitude: userLocation.latitude,
                            latitude: state.latitude!,
                            longitude: state.longitude!,
                            pickedImage: state.pickedPhoto);

                    if (property != null) {
                      widget.onSuccess();
                    }
                  },
                );
              },
            )
          ],
        ),
      ),
    );
  }
}
