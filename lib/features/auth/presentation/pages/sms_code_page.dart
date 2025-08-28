import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:neighbours/core/components/custom_gap.dart';
import 'package:neighbours/core/components/default_app_bar.dart';
import 'package:neighbours/core/extensions/context_ext.dart';
import 'package:neighbours/features/auth/presentation/widgets/pin_code_text_field.dart';
import '../../../../core/components/custom_button.dart';
import '../../../../core/constants/ui_constants.dart';
import '../cubits/otp/otp_cubit.dart';
import '../widgets/otp_timer.dart';

class SmsCodePage extends StatefulWidget {
  final String phone;
  final Function(String) onCodeCompleted;
  final Function(String) onRetry;
  final bool isError;
  final bool isLoading;

  const SmsCodePage({
    super.key,
    required this.phone,
    required this.onCodeCompleted,
    required this.onRetry,
    required this.isError,
    required this.isLoading,
  });

  @override
  State<SmsCodePage> createState() => _SmsCodePageState();
}

class _SmsCodePageState extends State<SmsCodePage>
    with TickerProviderStateMixin {
  static const int _codeLength = 6;
  static const int _otpTimer = 10;
  static const Duration _errorDuration = Duration(seconds: 2);

  late final AnimationController _controller;
  late final String _formattedPhone;
  final _otpController = TextEditingController();

  bool _isError = false;

  @override
  void initState() {
    super.initState();
    _initializeController();
    _formattedPhone = _formatPhone(widget.phone);
  }

  void _initializeController() {
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: _otpTimer),
    );
    _controller.forward();
    _controller.addListener(_handleControllerUpdate);
  }

  void _handleControllerUpdate() {
    if (_controller.isCompleted) {
      context.read<OtpCubit>().timerCompleted();
    }
  }

  @override
  void dispose() {
    _otpController.dispose();
    _controller.dispose();
    super.dispose();
  }

  void _onCodeCompleted(String code) {
    if (_isError) setState(() => _isError = false);

    if (code.length == _codeLength) {
      widget.onCodeCompleted(code);
    }
  }

  void _handleError() {
    setState(() => _isError = true);

    Future.delayed(_errorDuration, () {
      if (mounted) {
        setState(() {
          _isError = false;
          _otpController.clear();
        });
      }
    });
  }

  String _formatPhone(String phone) {
    if (phone.length == 11 && phone.startsWith('7')) {
      return '+7 (${phone.substring(1, 4)}) '
          '${phone.substring(4, 7)}-'
          '${phone.substring(7, 9)}-'
          '${phone.substring(9, 11)}';
    }
    return phone;
  }

  @override
  void didUpdateWidget(covariant SmsCodePage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isError == true) {
      _handleError();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const DefaultAppBar(
        showBackButton: true,
        title: 'Введите код',
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: UIConstants.defaultHorizontalPadding,
        ),
        child: _buildContent(context),
      ),
    );
  }

  Widget _buildContent(BuildContext context) {
    return ListView(
      children: [
        const VerticalGap(16),
        Text(
          'Введите код из смс, отправили код на номер\n$_formattedPhone.',
          style: context.text.bodyMedium,
        ),
        const VerticalGap(24),
        _buildPinCodeField(context),
        const SizedBox(height: 24),
        _buildTimerOrResendButton(context),
      ],
    );
  }

  Widget _buildPinCodeField(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final fieldWidth =
            UIConstants.calculateFieldWidth(constraints.maxWidth, 6);

        return PinCodeTextField(
          controller: _otpController,
          length: _codeLength,
          fieldWidth: fieldWidth,
          fieldHeight: fieldWidth + 15,
          borderWidth: 2,
          hasError: _isError,
          enabled: !widget.isLoading,
          borderColor: context.color.secondary,
          activeBorderColor: context.color.primary,
          borderRadius: BorderRadius.circular(12),
          textStyle: context.text.titleSmall,
          onComplete: _onCodeCompleted,
        );
      },
    );
  }

  Widget _buildTimerOrResendButton(BuildContext context) {
    return BlocBuilder<OtpCubit, OtpState>(
      builder: (context, otpState) {
        if (otpState.currentTimerState == OTPTimerStateEnum.running) {
          return Countdown(
            animation: StepTween(
              begin: _otpTimer,
              end: 0,
            ).animate(_controller),
          );
        }

        return CustomButton(
          onPressed: () {
            context.read<OtpCubit>().restartTimer();
            widget.onRetry(widget.phone);
            _controller.reset();
            _controller.forward();
          },
          label: Text(
            'Отправить заново',
            style: context.text.bodyMedium.copyWith(
              color: context.color.primaryText,
              fontWeight: FontWeight.w500,
            ),
          ),
        );
      },
    );
  }
}
