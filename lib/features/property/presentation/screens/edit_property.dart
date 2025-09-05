import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart' hide ImageSource;
import 'package:neighbours/core/components/custom_gap.dart';
import 'package:neighbours/core/components/default_app_bar.dart';
import 'package:neighbours/core/components/default_page_wrapper.dart';
import 'package:neighbours/core/components/primary_button.dart';
import 'package:image_picker/image_picker.dart';
import 'package:neighbours/core/extensions/context_ext.dart';
import 'package:neighbours/core/services/map_service.dart';
import 'package:neighbours/core/state/api_state.dart';
import 'package:neighbours/features/property/presentation/cubits/properties/properties_cubit.dart';
import 'package:neighbours/features/property/presentation/cubits/property_form/property_form_cubit.dart';
import '../../../../core/components/category_select_field.dart';
import '../../../../core/components/centered_map_picker.dart';
import '../../../../core/components/custom_label.dart';
import '../../../../core/components/image_picker_field.dart';
import '../../../../core/components/reusable_text_field.dart';
import '../../../home/presentation/widgets/property_marker.dart';

class EditProperty extends StatefulWidget {
  const EditProperty({super.key});

  @override
  State<EditProperty> createState() => _EditPropertyState();
}

class _EditPropertyState extends State<EditProperty> {
  late TextEditingController _propertyNameController;

  @override
  void initState() {
    final state = context.read<PropertyFormCubit>().state;
    _propertyNameController = TextEditingController(text: state.name);
    super.initState();
  }

  @override
  void dispose() {
    _propertyNameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final propertyFormCubit = context.read<PropertyFormCubit>();

    final isSubmitEnabled =
        context.select((PropertyFormCubit cubit) => cubit.isSubmitEnabled());
    final isUpdating = context.select<PropertiesCubit, bool>(
        (cubit) => cubit.state.updateState.isLoading);
    return Scaffold(
        appBar: const DefaultAppBar(
          showBackButton: true,
          title: 'Редактировать объект',
        ),
        body: BlocListener<PropertiesCubit, PropertiesState>(
          listener: (context, state) {
            if (state.updateState.isSuccess) {
              context.snackbar
                  .success(context, 'Объект недвижимости успешно обновлен');
            }
            if (state.updateState.isFailure) {
              context.snackbar.error(context, state.updateState.error!);
            }
          },
          child: Column(
            children: [
              AspectRatio(
                aspectRatio: 1,
                child: CenteredMapPicker(
                    initialCoordinates: propertyFormCubit.state.latitude != null
                        ? LatLng(propertyFormCubit.state.latitude!,
                            propertyFormCubit.state.longitude!)
                        : null,
                    centralWidget: const PropertyMarker(
                      isVerified: false,
                    ),
                    onCameraChange: (Point value) {
                      final pos = value.coordinates; // mapbox turf Position
                      context.read<PropertyFormCubit>().setCoordinates(
                            LatLng(pos.lat.toDouble(), pos.lng.toDouble()),
                          );
                    }),
              ),
              Expanded(
                child: DefaultPageWrapper(
                  padding: EdgeInsets.zero,
                  children: [
                    const VerticalGap(16),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Column(
                        children: [
                          const CustomLabel(text: 'Название', isRequired: true),
                          const VerticalGap(4),
                          BlocBuilder<PropertyFormCubit, PropertyFormState>(
                              buildWhen: (old, curr) =>
                                  old.nameError != curr.nameError ||
                                  old.name != curr.name,
                              builder: (context, state) {
                                return ReusableTextField(
                                  controller: _propertyNameController,
                                  hintText: 'Введите название',
                                  onChange: (value) => context
                                      .read<PropertyFormCubit>()
                                      .setName(value),
                                  errorText: state.nameError,
                                );
                              }),
                          const VerticalGap(16),
                          BlocSelector<PropertyFormCubit, PropertyFormState,
                              String?>(
                            selector: (state) => state.category,
                            builder: (context, selectedType) {
                              final cubit = context.read<PropertyFormCubit>();
                              return CategorySelectField<String>(
                                label: 'Категория',
                                selectedValue: selectedType,
                                items: cubit.typeLabels,
                                itemLabel: (label) => label,
                                onChanged: (label) {
                                  final apiValue =
                                      cubit.getApiTypeByLabel(label);
                                  cubit.setCategory(apiValue);
                                },
                                isSelected: (label, selectedValue) =>
                                    cubit.getApiTypeByLabel(label) ==
                                    selectedValue,
                              );
                            },
                          ),
                          const VerticalGap(16),
                          const CustomLabel(text: 'Фото'),
                          const VerticalGap(4),
                          BlocBuilder<PropertyFormCubit, PropertyFormState>(
                            builder: (context, state) {
                              return ImagePickerField(
                                pickedImage: state.pickedPhoto,
                                photoUrl: state.photoUrl,
                                onPickImage: () async {
                                  await context
                                      .read<PropertyFormCubit>()
                                      .pickImage(ImageSource.gallery);
                                },
                                onRemoveImage: () {
                                  context
                                      .read<PropertyFormCubit>()
                                      .removeImage();
                                },
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                    const Spacer(),
                    const VerticalGap(16),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: PrimaryButton(
                        text: isUpdating ? 'Ожидайте' : 'Изменить',
                        isEnabled: isSubmitEnabled,
                        onPressed: () async {
                          final formState =
                              context.read<PropertyFormCubit>().state;
                          final propertiesCubit =
                              context.read<PropertiesCubit>();
                          final updated = await propertiesCubit.updateProperty(
                            id: formState.id,
                            name: formState.name,
                            category: formState.category,
                            latitude: formState.latitude!,
                            longitude: formState.longitude!,
                            photo: formState.pickedPhoto,
                          );
                          if (updated != null) {
                            propertyFormCubit.resetOriginalProperty(updated);
                          }
                        },
                        isLoading: isUpdating,
                      ),
                    ),
                    const VerticalGap(16),
                  ],
                ),
              )
            ],
          ),
        ));
  }
}
