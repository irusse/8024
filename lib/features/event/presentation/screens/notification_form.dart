import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:neighbours/core/components/centered_map_picker.dart';
import 'package:neighbours/core/components/custom_gap.dart';
import 'package:neighbours/core/components/custom_label.dart';
import 'package:neighbours/core/components/default_app_bar.dart';
import 'package:neighbours/core/components/default_loading_overlay.dart';
import 'package:neighbours/core/components/default_page_wrapper.dart';
import 'package:neighbours/core/components/primary_button.dart';
import 'package:neighbours/core/components/reusable_text_field.dart';
import 'package:neighbours/core/constants/default_constants.dart';
import 'package:neighbours/core/cubits/events/events_cubit.dart';
import 'package:neighbours/core/cubits/user/user_cubit.dart';
import 'package:neighbours/core/extensions/context_ext.dart';
import 'package:neighbours/core/state/api_state.dart';
import 'package:neighbours/features/event/presentation/cubits/notification_form/notification_form_cubit.dart';
import 'package:neighbours/features/event/presentation/widgets/notification_category_marker.dart';
import '../../../../core/services/map_service.dart';
import '../widgets/notification_type_selector.dart';

class NotificationForm extends StatefulWidget {
  const NotificationForm({super.key});

  @override
  State<NotificationForm> createState() => _NotificationFormState();
}

class _NotificationFormState extends State<NotificationForm> {
  late final TextEditingController _descriptionTextController;

  @override
  void initState() {
    setData();

    _descriptionTextController = TextEditingController(
        text: context.read<NotificationFormCubit>().state.description);
    super.initState();
  }

  void setData() async {
    final eventsCubit = context.read<EventsCubit>();
    final notificationFormCubit = context.read<NotificationFormCubit>();
    if (eventsCubit.state.categories.isEmpty) {
      await eventsCubit.fetchEventCategories();
    }
    final defaultCategory = eventsCubit.state.categories.firstWhereOrNull(
      (c) => c.type == DefaultConstants.notification,
    );
    if (defaultCategory != null &&
        notificationFormCubit.state.categoryId == null &&
        mounted) {
      context
          .read<NotificationFormCubit>()
          .changeCategoryId(defaultCategory.id);
    }
  }

  Future<void> _submit(NotificationFormState state, bool isNew) async {
    final categoryId = state.categoryId;
    final category =
        context.read<EventsCubit>().getEventCategoryById(categoryId);
    if (category == null) {
      context.snackbar.error(context, 'Категория не найдена');
      return;
    }

    final communityId =
        context.read<UserCubit>().state.user.communities.first.id;

    if (isNew) {
      await context.read<EventsCubit>().createNotification(
            title: category.name,
            latitude: state.latitude,
            longitude: state.longitude,
            categoryId: category.id,
            description: state.description,
            communityId: communityId,
          );
    } else {
      await context.read<EventsCubit>().updateNotification(
            title: category.name,
            latitude: state.latitude,
            longitude: state.longitude,
            categoryId: category.id,
            description: state.description,
            id: state.id.toString(),
          );
    }
  }

  @override
  void dispose() {
    _descriptionTextController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final notificationFormCubit = context.read<NotificationFormCubit>();
    final isNew = notificationFormCubit.isNew();
    return Scaffold(
      appBar: DefaultAppBar(
        showBackButton: true,
        title: isNew ? 'Создать оповещение' : 'Редактировать оповещение',
      ),
      body: BlocConsumer<EventsCubit, EventsState>(
        listenWhen: (prev, curr) =>
            prev.createNotificationState != curr.createNotificationState ||
            prev.updateNotificationState != curr.updateNotificationState,
        listener: (context, state) {
          state.createNotificationState.handleApiState(
              onSuccess: () => context.pop(),
              onError: (error) => context.snackbar.show(context, error));
          state.updateNotificationState.handleApiState(
              onSuccess: () {
                context.snackbar
                    .success(context, "Оповещение успешно изменено");
                context.pop();
              },
              onError: (error) => context.snackbar.show(context, error));
        },
        builder: (context, state) => state.categoriesState.isLoading
            ? const DefaultLoadingOverlay()
            : Column(
                children: [
                  AspectRatio(
                    aspectRatio: 1,
                    child: CenteredMapPicker(
                        initialCoordinates:
                            notificationFormCubit.state.latitude != 0 &&
                                    notificationFormCubit.state.longitude != 0
                                ? LatLng(notificationFormCubit.state.latitude,
                                    notificationFormCubit.state.longitude)
                                : null,
                        onCameraChange: (point) => context
                            .read<NotificationFormCubit>()
                            .onCoordsChange(point),
                        centralWidget: BlocSelector<NotificationFormCubit,
                            NotificationFormState, int?>(
                          selector: (cubit) => cubit.categoryId,
                          builder: (context, categoryId) {
                            final selectedCategory = context
                                .read<EventsCubit>()
                                .getEventCategoryById(categoryId);
                            return selectedCategory != null
                                ? NotificationCategoryMarker(
                                    eventCategoryEntity: selectedCategory)
                                : const SizedBox.shrink();
                          },
                        )),
                  ),
                  Expanded(
                    child: DefaultPageWrapper(
                      children: [
                        const VerticalGap(16),
                        const CustomLabel(
                          text: 'Категория',
                          isRequired: true,
                        ),
                        const VerticalGap(16),
                        BlocSelector<NotificationFormCubit,
                            NotificationFormState, int?>(
                          selector: (state) => state.categoryId,
                          builder: (context, selectedCategory) {
                            return NotificationTypeSelector(
                              selectedType: selectedCategory,
                              onSelected: (categoryId) {
                                context
                                    .read<NotificationFormCubit>()
                                    .changeCategoryId(categoryId);
                              },
                            );
                          },
                        ),
                        const VerticalGap(16),
                        const CustomLabel(
                          text: 'Описание оповещения',
                          isRequired: true,
                        ),
                        const VerticalGap(4),
                        BlocBuilder<NotificationFormCubit,
                            NotificationFormState>(builder: (context, state) {
                          final isDescriptionEmpty =
                              state.description.trim().isEmpty;
                          return ReusableTextField(
                            controller: _descriptionTextController,
                            hintText: 'Введите описание оповещения...',
                            maxLines: 4,
                            errorText:
                                (state.descriptionDirty && isDescriptionEmpty)
                                    ? 'Описание обязательно'
                                    : null,
                            onChange: (value) => context
                                .read<NotificationFormCubit>()
                                .changeDescription(value),
                          );
                        }),
                        const Spacer(),
                        const VerticalGap(16),
                        BlocBuilder<NotificationFormCubit,
                                NotificationFormState>(
                            builder: (context, notificationFormState) {
                          return PrimaryButton(
                              isLoading:
                                  state.createNotificationState.isLoading ||
                                      state.updateNotificationState.isLoading,
                              text: isNew ? 'Добавить' : 'Изменить',
                              isEnabled: context
                                  .read<NotificationFormCubit>()
                                  .isSubmitEnabled(),
                              onPressed: () =>
                                  _submit(notificationFormState, isNew));
                        }),
                        const VerticalGap(16),
                      ],
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}
