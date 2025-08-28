import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:neighbours/core/components/custom_gap.dart';
import 'package:neighbours/core/components/custom_label.dart';
import 'package:neighbours/core/components/primary_button.dart';
import 'package:neighbours/core/constants/ui_constants.dart';
import 'package:neighbours/core/extensions/context_ext.dart';
import 'package:neighbours/features/home/presentation/cubits/create_community_form/create_community_form_cubit.dart';
import '../../../../core/cubits/user/user_cubit.dart';
import '../../../../core/cubits/user_location/user_location_cubit.dart';
import '../../../../core/services/snackbar_service.dart';
import '../../../../core/utils/sheet_utils.dart';
import '../../../auth/presentation/widgets/pin_code_text_field.dart';

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
  bool loading = false;
  String? error;

  @override
  void dispose() {
    _codeController.dispose();
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
            const CustomLabel(text: 'Пригласительный код'),
            const VerticalGap(8),
            _buildCodeField(context, state),
            const VerticalGap(8),
            PrimaryButton(
              text: 'Вступить',
              isEnabled:
                  context.read<CreateCommunityFormCubit>().isJoinEnabled(),
              isLoading: state.isJoining,
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
    final newUser = await context.read<CreateCommunityFormCubit>().submit(
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
          context, "Вы успешно встпили в сообщество ${newCommunity.name}");

      // Вызываем функцию для обновления данных
      widget.onDataFetchRequired?.call();
    }
  }

  Widget _buildCodeField(BuildContext context, CreateCommunityFormState state) {
    final cubit = context.read<CreateCommunityFormCubit>();
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
          hasError: state.error != null,
          enabled: !state.isJoining,
          textInputType: TextInputType.text,
          borderColor: context.color.secondary,
          activeBorderColor: context.color.primary,
          borderRadius: BorderRadius.circular(12),
          textStyle: context.text.titleSmall,
          onChange: (value) => cubit.onCommunityCodeChanged(value),
          onComplete: (value) {},
        );
      },
    );
  }
}
