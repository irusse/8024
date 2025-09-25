import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:neighbours/core/extensions/context_ext.dart';
import 'package:neighbours/features/property/presentation/cubits/properties/properties_cubit.dart';

import '../../../../core/components/bottom_sheet_dialog.dart';
import '../../../../core/components/custom_gap.dart';
import '../../../../core/components/custom_label.dart';
import '../../../../core/components/primary_button.dart';
import '../../../../core/constants/ui_constants.dart';
import '../../../../core/cubits/user/user_cubit.dart';
import '../../../../core/cubits/user_location/user_location_cubit.dart';
import '../../../../core/di/injection.dart';
import '../../../auth/presentation/widgets/pin_code_text_field.dart';

class VerifyPropertyDialog extends StatefulWidget {
  const VerifyPropertyDialog({super.key});

  static void showDialog(BuildContext context) {
    showBaseBottomSheet(
        context: context,
        child: MultiBlocProvider(providers: [
          BlocProvider.value(
            value: getIt<UserLocationCubit>(),
          ),
          BlocProvider.value(
            value: getIt<UserCubit>(),
          ),
          BlocProvider.value(
            value: getIt<PropertiesCubit>(),
          ),
        ], child: VerifyPropertyDialog()));
  }

  @override
  State<VerifyPropertyDialog> createState() => _VerifyPropertyDialogState();
}

class _VerifyPropertyDialogState extends State<VerifyPropertyDialog> {
  final _codeController = TextEditingController();

  @override
  void dispose() {
    _codeController.dispose();
    super.dispose();
  }

  void _onConfirm() {}

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const VerticalGap(8),
        const CustomLabel(text: 'Введите код'),
        const VerticalGap(8),
        _buildCodeField(context, false, false),
        const VerticalGap(8),
        PrimaryButton(
          text: 'Подтвердить',
          isEnabled: true,
          isLoading: false,
          onPressed: _onConfirm,
        ),
      ],
    );
  }

  Widget _buildCodeField(BuildContext context, bool isLoading, bool hasError) {
    final cubit = context.read<PropertiesCubit>();
    return LayoutBuilder(
      builder: (context, constraints) {
        final fieldWidth = UIConstants.calculateFieldWidth(
            constraints.maxWidth, cubit.propertyVerificationCodeLength);

        return PinCodeTextField(
          controller: _codeController,
          length: cubit.propertyVerificationCodeLength,
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
          onChange: (value) {},
          onComplete: (value) {},
        );
      },
    );
  }
}
