import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:neighbours/core/components/custom_gap.dart';
import 'package:neighbours/core/components/custom_label.dart';
import 'package:neighbours/core/components/primary_button.dart';
import 'package:neighbours/core/constants/ui_constants.dart';
import 'package:neighbours/core/extensions/context_ext.dart';
import 'package:neighbours/core/state/api_state.dart';
import 'package:neighbours/features/community/presentation/cubits/community/community_cubit.dart';
import '../../../../core/cubits/user/user_cubit.dart';
import '../../../../core/cubits/user_location/user_location_cubit.dart';
import '../../../../core/services/snackbar_service.dart';
import '../../../../core/utils/sheet_utils.dart';
import '../../../auth/presentation/widgets/pin_code_text_field.dart';
import '../cubits/community_access_form/community_access_cubit.dart';

class JoinCommunityDialog extends StatefulWidget {
  final VoidCallback? onDataFetchRequired;

  const JoinCommunityDialog({
    super.key,
    this.onDataFetchRequired,
  });

  @override
  State<JoinCommunityDialog> createState() => _JoinCommunityDialogState();
}

class _JoinCommunityDialogState extends State<JoinCommunityDialog> {
  final _codeController = TextEditingController();

  @override
  void dispose() {
    _codeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isUserLocationLoading = context
        .select<UserLocationCubit, bool>((cubit) => cubit.state.isLoading);
    final isSubmitEnabled = context
        .select<CommunityAccessCubit, bool>((cubit) => cubit.isJoinEnabled());
    return BlocConsumer<CommunityCubit, CommunityState>(
      listenWhen: (previous, current) =>
          previous.joinCommunityState != previous.joinCommunityState,
      listener: (context, state) {
        if (state.joinCommunityState.isFailure) {
          context.snackbar.error(context, state.joinCommunityState.error!,
              position: SnackBarPosition.top);
        }
      },
      builder: (context, state) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const VerticalGap(8),
            const CustomLabel(text: 'Пригласительный код'),
            const VerticalGap(8),
            _buildCodeField(context, state.joinCommunityState.isLoading,
                state.joinCommunityState.isFailure),
            const VerticalGap(8),
            PrimaryButton(
              text: 'Вступить',
              isEnabled: isSubmitEnabled,
              isLoading:
                  state.joinCommunityState.isLoading || isUserLocationLoading,
              onPressed: _onConfirm,
            ),
          ],
        );
      },
    );
  }

  void _onConfirm() async {
    final userCubit = context.read<UserCubit>();
    final userLocation = await context.read<UserLocationCubit>().getPosition();
    if (userLocation == null || !mounted) return;
    final newUser = await context.read<CommunityCubit>().join(
          code: context.read<CommunityAccessCubit>().state.code!,
          userLatitude: userLocation.latitude,
          userLongitude: userLocation.longitude,
        );
    if (newUser != null) {
      userCubit.setUser(newUser);
      if (!mounted) return;
      await SheetUtils.ensureBottomSheetClosed(context);
      final newCommunity = newUser.communities.first;
      if (!mounted) return;
      context.snackbar.success(
          context, "Вы успешно вступили в сообщество ${newCommunity.name}");
      widget.onDataFetchRequired?.call();
    }
  }

  Widget _buildCodeField(BuildContext context, bool isLoading, bool hasError) {
    final cubit = context.read<CommunityAccessCubit>();
    final codeLength = cubit.communityCodeLength;
    return LayoutBuilder(
      builder: (context, constraints) {
        final fieldWidth =
            UIConstants.calculateFieldWidth(constraints.maxWidth, codeLength);

        return PinCodeTextField(
          controller: _codeController,
          length: 6,
          fieldWidth: fieldWidth,
          fieldHeight: fieldWidth + 15,
          borderWidth: 2,
          hasError: hasError,
          enabled: !isLoading,
          textInputType: TextInputType.text,
          borderColor: context.color.secondary,
          activeBorderColor: context.color.primary,
          borderRadius: BorderRadius.circular(12),
          textStyle: context.text.titleSmall,
          onChange: (value) => cubit.onCodeChanged(value),
          onComplete: (value) {},
        );
      },
    );
  }
}
