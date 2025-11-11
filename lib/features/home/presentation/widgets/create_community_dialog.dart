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
import 'package:neighbours/core/state/api_state.dart';
import 'package:neighbours/core/utils/sheet_utils.dart';
import 'package:neighbours/features/community/presentation/cubits/community/community_cubit.dart';
import 'package:neighbours/core/components/reusable_text_field.dart';
import 'package:neighbours/features/home/presentation/cubits/community_access_form/community_access_cubit.dart';

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

  void _onSubmit() async {
    final userCubit = context.read<UserCubit>();
    final userLocation = await context.read<UserLocationCubit>().getPosition();
    if (userLocation == null || !context.mounted) return;
    final newUser = await context.read<CommunityCubit>().create(
          name: context.read<CommunityAccessCubit>().state.name!,
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
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<CommunityCubit, CommunityState>(
      listenWhen: (previous, current) =>
          previous.createCommunityState != current.createCommunityState,
      listener: (context, state) {
        if (state.createCommunityState.isFailure) {
          context.snackbar.error(context, state.createCommunityState.error!,
              position: SnackBarPosition.top);
        }
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
            BlocSelector<CommunityAccessCubit, CommunityAccessState, String?>(
              selector: (cubit) => cubit.nameError,
              builder: (context, error) => ReusableTextField(
                controller: _nameController,
                hintText: 'Введите название (Кузьмино 505)',
                errorText: error,
                onChange: (value) {
                  context.read<CommunityAccessCubit>().onNameChanged(value);
                },
              ),
            ),
            const VerticalGap(24),
            BlocBuilder<CommunityAccessCubit, CommunityAccessState>(
                builder: (context, formState) {
              return PrimaryButton(
                text: 'Создать',
                isLoading: state.createCommunityState.isLoading,
                isEnabled:
                    context.read<CommunityAccessCubit>().isCreateEnabled(),
                onPressed: _onSubmit,
              );
            })
          ],
        );
      },
    );
  }
}
