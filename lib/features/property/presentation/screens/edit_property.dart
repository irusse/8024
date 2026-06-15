import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart' hide ImageSource;
import 'package:neighbours/core/components/custom_gap.dart';
import 'package:neighbours/core/components/default_app_bar.dart';
import 'package:neighbours/core/components/default_page_wrapper.dart';
import 'package:neighbours/core/components/map_preview.dart';
import 'package:neighbours/core/components/primary_button.dart';
import 'package:image_picker/image_picker.dart';
import 'package:neighbours/core/extensions/context_ext.dart';
import 'package:neighbours/core/router/app_routes.dart';
import 'package:neighbours/core/services/map_service.dart';
import 'package:neighbours/core/state/api_state.dart';
import 'package:neighbours/features/property/presentation/cubits/properties/properties_cubit.dart';
import 'package:neighbours/features/property/presentation/cubits/property_form/property_form_cubit.dart';
import '../../../../core/components/category_select_field.dart';
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

  Future<void> _openMapPicker() async {
    final propertyFormCubit = context.read<PropertyFormCubit>();
    final initialCoords = propertyFormCubit.state.latitude != null &&
            propertyFormCubit.state.longitude != null
        ? LatLng(
            propertyFormCubit.state.latitude!,
            propertyFormCubit.state.longitude!,
          )
        : null;

    final result = await context.push<Point>(
      AppRoutePath.fullMapPicker,
      extra: {
        'centralWidget': const PropertyMarker(isVerified: false),
        'initialCoordinates': initialCoords,
        'title': 'Выберите точку на карте',
      },
    );

    if (result != null && mounted) {
      propertyFormCubit.setCoordinates(
        LatLng(
          result.coordinates.lat.toDouble(),
          result.coordinates.lng.toDouble(),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final propertyFormCubit = context.read<PropertyFormCubit>();
    final height = MediaQuery.of(context).size.height;

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
              context.pop();
            }
            if (state.updateState.isFailure) {
              context.snackbar.error(context, state.updateState.error!);
            }
          },
          child: Column(
            children: [
              const VerticalGap(16),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const CustomLabel(
                      text: 'Выберите точку на карте',
                      isRequired: true,
                    ),
                    const VerticalGap(8),
                    BlocBuilder<PropertyFormCubit, PropertyFormState>(
                      buildWhen: (prev, curr) =>
                          prev.latitude != curr.latitude ||
                          prev.longitude != curr.longitude,
                      builder: (context, state) {
                        if (state.latitude == null || state.longitude == null) {
                          return GestureDetector(
                            onTap: _openMapPicker,
                            child: Container(
                              height: height / 5,
                              decoration: BoxDecoration(
                                color: context.color.secondary,
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.location_on_outlined,
                                      size: 48,
                                      color: context.color.primary,
                                    ),
                                    const VerticalGap(8),
                                    Text(
                                      'Нажмите, чтобы выбрать локацию',
                                      style: context.text.bodyMedium.copyWith(
                                        color: context.color.primary,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        }
                        return MapPreview(
                          key: ValueKey('${state.latitude}_${state.longitude}'),
                          radius: 16,
                          zoom: 16,
                          height: height / 5,
                          onClick: _openMapPicker,
                          latitude: state.latitude!,
                          longitude: state.longitude!,
                          customPoint: const PropertyMarker(isVerified: false),
                        );
                      },
                    ),
                  ],
                ),
              ),
              const VerticalGap(16),
              Expanded(
                child: DefaultPageWrapper(
                  padding: EdgeInsets.zero,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Column(
                        children: [
                          const CustomLabel(text: 'Название', isRequired: true),
                          const VerticalGap(8),
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
