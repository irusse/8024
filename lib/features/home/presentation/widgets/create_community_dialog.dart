import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:neighbours/core/components/bottom_sheet_dialog.dart';
import 'package:neighbours/core/components/custom_gap.dart';
import 'package:neighbours/core/components/custom_label.dart';
import 'package:neighbours/core/components/primary_button.dart';
import 'package:neighbours/core/cubits/user/user_cubit.dart';
import 'package:neighbours/core/cubits/user_location/user_location_cubit.dart';
import 'package:neighbours/core/extensions/context_ext.dart';
import 'package:neighbours/core/services/snackbar_service.dart';
import 'package:neighbours/core/utils/sheet_utils.dart';
import 'package:neighbours/features/home/presentation/cubits/create_community_form/create_community_form_cubit.dart';
import 'package:neighbours/core/components/reusable_text_field.dart';

import 'invite_neighbors_dialog.dart';

class CreateCommunityDialog extends StatefulWidget {
  final VoidCallback? onDataFetchRequired;

  const CreateCommunityDialog({
    super.key,
    this.onDataFetchRequired,
  });

  @override
  State<CreateCommunityDialog> createState() => _CreateCommunityDialogState();
}

class _CreateCommunityDialogState extends State<CreateCommunityDialog> {
  final _nameController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<CreateCommunityFormCubit, CreateCommunityFormState>(
      listenWhen: (previous, current) =>
          previous.error != current.error && current.error != null,
      listener: (context, state) {
        context.snackbar
            .error(context, state.error!, position: SnackBarPosition.top);
      },
      builder: (context, state) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const VerticalGap(8),
            const CustomLabel(
              text: 'Название',
              isRequired: true,
            ),
            const VerticalGap(8),
            ReusableTextField(
              controller: _nameController,
              hintText: 'Введите название (Кузьмино 505)',
              errorText: state.nameError,
              onChange: (value) {
                context.read<CreateCommunityFormCubit>().onNameChanged(value);
              },
            ),
            const VerticalGap(8),
            const CustomLabel(text: 'Состояние'),
            const VerticalGap(8),
            ReusableTextField(
              hintText: 'Не подтвержден',
              controller: TextEditingController(),
              readOnly: true,
            ),
            const VerticalGap(8),
            Text(
              'Соседи еще не подтвердили',
              style: context.text.bodyMedium
                  .copyWith(color: context.color.secondaryText),
            ),
            const VerticalGap(16),
            PrimaryButton(
              text: 'Создать',
              isLoading: state.isCreating,
              isEnabled:
                  context.read<CreateCommunityFormCubit>().isCreateEnabled(),
              onPressed: () async {
                final userCubit = context.read<UserCubit>();
                final userLocation =
                    await context.read<UserLocationCubit>().getPosition();
                if (userLocation == null || !context.mounted) return;
                final newUser =
                    await context.read<CreateCommunityFormCubit>().submit(
                          userLatitude: userLocation.latitude,
                          userLongitude: userLocation.longitude,
                        );
                if (newUser != null) {
                  userCubit.setUser(newUser);
                  if (!context.mounted) return;

                  final newCommunity = newUser.communities.first;
                  await SheetUtils.ensureBottomSheetClosed(context);
                  if (!context.mounted) return;
                  showBaseBottomSheet(
                      context: context,
                      title:
                          'Пригласите минимум 3 соседей в радиусе 500 м от вашего объекта для создания сообщества',
                      child: InviteNeighborsDialog(
                        communityName: newCommunity.name,
                        communityCode: newCommunity.joinCode,
                      ));

                  widget.onDataFetchRequired?.call();
                }
              },
            ),
          ],
        );
      },
    );
  }
}
