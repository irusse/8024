import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:neighbours/core/components/category_select_field.dart';
import 'package:neighbours/core/components/centered_map_picker.dart';
import 'package:neighbours/core/components/custom_gap.dart';
import 'package:neighbours/core/components/custom_label.dart';
import 'package:neighbours/core/components/custom_swtich.dart';
import 'package:neighbours/core/components/default_loading_overlay.dart';
import 'package:neighbours/core/domain/entities/event/event_category_entity.dart';
import 'package:neighbours/core/extensions/context_ext.dart';
import 'package:neighbours/core/state/api_state.dart';
import 'package:neighbours/features/event/presentation/widgets/date_time_select_field.dart';
import 'package:neighbours/core/components/default_app_bar.dart';
import 'package:neighbours/core/components/image_picker_field.dart';
import 'package:neighbours/core/components/primary_button.dart';
import 'package:neighbours/core/components/reusable_text_field.dart';
import 'package:neighbours/core/cubits/events/events_cubit.dart';
import 'package:neighbours/features/event/presentation/cubits/event_form/event_form_cubit.dart';
import 'package:image_picker/image_picker.dart';
import 'package:neighbours/features/event/presentation/widgets/event_question_builder.dart';
import '../../../../core/constants/default_constants.dart';
import '../../../../core/constants/ui_constants.dart';
import '../../../../core/cubits/user/user_cubit.dart';
import '../../../../core/services/map_service.dart';
import '../widgets/event_create_marker.dart';

class EventForm extends StatefulWidget {
  const EventForm({super.key});

  @override
  State<EventForm> createState() => _EventFormState();
}

class _EventFormState extends State<EventForm> {
  final _nameEditingController = TextEditingController();
  final _descriptionEditingController = TextEditingController();

  @override
  void initState() {
    setData();
    _initializeControllers();
    super.initState();
  }

  void _initializeControllers() {
    final eventFormCubit = context.read<EventFormCubit>();
    _nameEditingController.text = eventFormCubit.state.title;
    _descriptionEditingController.text = eventFormCubit.state.description;
  }

  void setData() async {
    final eventsCubit = context.read<EventsCubit>();
    if (eventsCubit.state.categories.isEmpty) {
      await eventsCubit.fetchEventCategories();
    }
  }

  @override
  void dispose() {
    _nameEditingController.dispose();
    _descriptionEditingController.dispose();
    super.dispose();
  }

  Future<void> _submit(EventFormState state) async {
    final categoryId = state.categoryId;
    final eventFormCubit = context.read<EventFormCubit>();
    final isNew = eventFormCubit.isNew();

    final communityId =
        context.read<UserCubit>().state.user.communities.first.id;

    if (isNew) {
      await context.read<EventsCubit>().createEvent(
          title: state.title,
          latitude: state.latitude,
          longitude: state.longitude,
          categoryId: categoryId!,
          description: state.description,
          communityId: communityId,
          pickedImage: state.image,
          eventDateTime: state.selectedDateTime,
          hasVoting: state.hasVoting,
          votingQuestion: state.votingQuestion,
          votingOptions: state.votingOptions);
    } else {
      await context.read<EventsCubit>().updateEvent(
          id: state.id.toString(),
          title: state.title,
          latitude: state.latitude,
          longitude: state.longitude,
          categoryId: categoryId!,
          description: state.description,
          image: state.imageUrl,
          pickedImage: state.image,
          eventDateTime: state.selectedDateTime!,
          hasVoting: state.hasVoting,
          votingQuestion: state.votingQuestion,
          votingOptions: state.votingOptions);
    }
  }

  @override
  Widget build(BuildContext context) {
    final hasVoting =
        context.select<EventFormCubit, bool>((cubit) => cubit.state.hasVoting);
    final eventsCubit = context.read<EventsCubit>();
    final eventFormCubit = context.read<EventFormCubit>();
    final isNew = eventFormCubit.isNew();

    return Scaffold(
      appBar: DefaultAppBar(
          showBackButton: true,
          title: isNew ? 'Создать мероприятие' : 'Редактировать мероприятие'),
      body: BlocConsumer<EventsCubit, EventsState>(
        listenWhen: (prev, curr) =>
            prev.createEventState != curr.createEventState ||
            prev.updateEventState != curr.updateEventState,
        listener: (context, state) {
          state.createEventState.handleApiState(
              onSuccess: () {
                context.snackbar
                    .success(context, "Мероприятие успешно создано");
                context.pop();
              },
              onError: (error) => context.snackbar.show(context, error));
          state.updateEventState.handleApiState(
              onSuccess: () {
                context.snackbar
                    .success(context, "Мероприятие успешно изменено");
                context.pop();
              },
              onError: (error) => context.snackbar.show(context, error));
        },
        builder: (context, eventsState) => eventsState.categoriesState.isLoading
            ? const DefaultLoadingOverlay()
            : Column(
                children: [
                  AspectRatio(
                    aspectRatio: 1.4,
                    child: CenteredMapPicker(
                      initialCoordinates: eventFormCubit.state.latitude != 0 &&
                              eventFormCubit.state.longitude != 0
                          ? LatLng(eventFormCubit.state.latitude,
                              eventFormCubit.state.longitude)
                          : null,
                      onCameraChange: (pos) => context
                          .read<EventFormCubit>()
                          .setCoordinates(
                              longitude: pos.coordinates.lng.toDouble(),
                              latitude: pos.coordinates.lat.toDouble()),
                      centralWidget: const EventCreateMarker(),
                    ),
                  ),
                  Flexible(
                    child: SingleChildScrollView(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: UIConstants.defaultHorizontalPadding),
                        child: Column(children: [
                          const VerticalGap(16),
                          const CustomLabel(
                            text: 'Название мероприятия',
                            isRequired: true,
                          ),
                          const VerticalGap(8),
                          BlocBuilder<EventFormCubit, EventFormState>(
                              builder: (context, state) {
                            return ReusableTextField(
                              controller: _nameEditingController,
                              errorText: state.titleError,
                              hintText: 'Уборка деревьев',
                              onChange: (value) =>
                                  context.read<EventFormCubit>().setName(value),
                            );
                          }),
                          const VerticalGap(16),
                          BlocSelector<EventFormCubit, EventFormState, int?>(
                            selector: (cubit) => cubit.categoryId,
                            builder: (context, categoryId) {
                              final selectedCategory =
                                  eventsCubit.getEventCategoryById(categoryId);

                              return CategorySelectField<EventCategoryEntity>(
                                label: 'Выберите категорию',
                                selectedValue: selectedCategory?.name,
                                items: eventsState.categories
                                    .where(
                                        (c) => c.type == DefaultConstants.event)
                                    .toList(),
                                itemLabel: (category) => category.name,
                                onChanged: (category) {
                                  context
                                      .read<EventFormCubit>()
                                      .setCategoryId(category.id);
                                },
                              );
                            },
                          ),
                          const VerticalGap(16),
                          const CustomLabel(
                            text: 'Обложка',
                          ),
                          const VerticalGap(8),
                          BlocBuilder<EventFormCubit, EventFormState>(
                            buildWhen: (prev, curr) =>
                                prev.image != curr.image ||
                                prev.imageUrl != curr.imageUrl,
                            builder: (context, state) {
                              return ImagePickerField(
                                pickedImage: state.image,
                                photoUrl: state.imageUrl,
                                isCircular: false,
                                onPickImage: () async {
                                  await context
                                      .read<EventFormCubit>()
                                      .pickEventImage(ImageSource.gallery);
                                },
                                onRemoveImage: () {
                                  context.read<EventFormCubit>().removeImage();
                                },
                              );
                            },
                          ),
                          const VerticalGap(16),
                          const CustomLabel(
                            text: 'Описание мероприятия',
                          ),
                          const VerticalGap(8),
                          BlocBuilder<EventFormCubit, EventFormState>(
                              buildWhen: (prev, curr) =>
                                  prev.description != curr.description,
                              builder: (context, state) {
                                return ReusableTextField(
                                  controller: _descriptionEditingController,
                                  hintText: 'Введите описание мероприятия...',
                                  maxLines: 4,
                                  onChange: (value) => context
                                      .read<EventFormCubit>()
                                      .setDescription(value),
                                );
                              }),
                          const VerticalGap(16),
                          BlocBuilder<EventFormCubit, EventFormState>(
                            builder: (context, state) {
                              return DateTimeSelectField(
                                selectedDateTime: state.selectedDateTime,
                                isRequired: true,
                                onDateTimeChanged: (dateTime) {
                                  context
                                      .read<EventFormCubit>()
                                      .setDateTime(dateTime);
                                },
                              );
                            },
                          ),
                          const VerticalGap(16),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Добавить голосование',
                                style: context.text.bodyLarge,
                              ),
                              CustomSwitch(
                                  value: hasVoting,
                                  width: 48,
                                  height: 32,
                                  isEnabled: isNew,
                                  backgroundOnColor: context.color.primary,
                                  backgroundOffColor: context.color.secondary,
                                  thumbColor: Colors.white,
                                  thumbSize: 27,
                                  onToggle: (value) => context
                                      .read<EventFormCubit>()
                                      .setHasVoting(value))
                            ],
                          ),
                          if (hasVoting && isNew) const EventQuestionBuilder(),
                          const VerticalGap(16),
                          BlocBuilder<EventFormCubit, EventFormState>(
                            builder: (context, eventFormState) {
                              return PrimaryButton(
                                text: isNew ? 'Создать' : 'Редактировать',
                                isLoading:
                                    eventsState.createEventState.isLoading ||
                                        eventsState.updateEventState.isLoading,
                                isEnabled: context
                                    .read<EventFormCubit>()
                                    .isSubmitEnabled(),
                                onPressed: () => _submit(eventFormState),
                              );
                            },
                          ),
                          const VerticalGap(24)
                        ]),
                      ),
                    ),
                  )
                ],
              ),
      ),
    );
  }
}
