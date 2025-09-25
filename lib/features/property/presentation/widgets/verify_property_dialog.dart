import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:neighbours/core/extensions/context_ext.dart';
import 'package:neighbours/core/state/api_state.dart';
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
  final int propertyId;

  const VerifyPropertyDialog({super.key, required this.propertyId});

  static void showDialog(BuildContext context, int propertyId) {
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
        ], child: VerifyPropertyDialog(propertyId: propertyId)));
  }

  @override
  State<VerifyPropertyDialog> createState() => _VerifyPropertyDialogState();
}

class _VerifyPropertyDialogState extends State<VerifyPropertyDialog> {
  final _codeController = TextEditingController();
  late final ValueNotifier<String> _codeNotifier;
  late final ValueNotifier<bool> _isEnabledNotifier;

  @override
  void initState() {
    super.initState();
    _codeNotifier = ValueNotifier<String>('');
    _isEnabledNotifier = ValueNotifier<bool>(false);

    _codeController.addListener(() {
      _codeNotifier.value = _codeController.text;
      _isEnabledNotifier.value = _codeController.text.length == 6;
    });
  }

  @override
  void dispose() {
    _codeController.dispose();
    _codeNotifier.dispose();
    _isEnabledNotifier.dispose();
    super.dispose();
  }

  Future<void> _onConfirm() async {
    if (_codeController.text.length == 6) {
      await context.read<PropertiesCubit>().confirmPropertyByCode(
            propertyId: widget.propertyId,
            code: _codeController.text,
          );
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<PropertiesCubit, PropertiesState>(
      listenWhen: (prev, curr) => prev.verifyState != curr.verifyState,
      listener: (context, state) {
        if (state.verifyState.isSuccess) {
          context.pop();
        }
      },
      builder: (context, state) {
        final isLoading = state.verifyState.isLoading;
        final hasError = state.verifyState.isFailure;

        return Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const VerticalGap(8),
            const CustomLabel(text: 'Введите код'),
            const VerticalGap(8),
            _buildCodeField(context, isLoading, hasError),
            const VerticalGap(8),
            ValueListenableBuilder<bool>(
              valueListenable: _isEnabledNotifier,
              builder: (context, isEnabled, _) {
                return PrimaryButton(
                  text: 'Подтвердить',
                  isEnabled: isEnabled && !isLoading,
                  isLoading: isLoading,
                  onPressed: isEnabled ? _onConfirm : () {},
                );
              },
            ),
          ],
        );
      },
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
          onChange: (value) {
            // ValueNotifier обновляется автоматически через контроллер
          },
          onComplete: (value) {
            // Автоматически вызовем подтверждение при заполнении всех полей
          },
        );
      },
    );
  }
}
