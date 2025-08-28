import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:neighbours/core/components/custom_gap.dart';
import 'package:neighbours/core/components/default_app_bar.dart';
import 'package:neighbours/core/extensions/context_ext.dart';
import 'package:neighbours/core/components/phone_input_field.dart';
import 'package:neighbours/core/components/primary_button.dart';
import 'package:neighbours/core/router/app_routes.dart';
import 'package:neighbours/core/services/snackbar_service.dart';
import '../../../../core/constants/ui_constants.dart';
import '../cubits/auth/auth_cubit.dart';

class PhoneAuthPage extends StatefulWidget {
  const PhoneAuthPage({super.key});

  @override
  State<PhoneAuthPage> createState() => _PhoneAuthPageState();
}

class _PhoneAuthPageState extends State<PhoneAuthPage> {
  final _controller = TextEditingController();

  void _onContinue() {
    final phone = '7${_controller.text.replaceAll(RegExp(r'\D'), '')}';
    if (phone.length == 11) {
      context.read<AuthCubit>().phoneLogin(phone);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthCubit, AuthState>(
      listener: (context, state) {
        if (state is AuthAuthenticated || state is SmsSent) {
          final phone = '7${_controller.text.replaceAll(RegExp(r'\D'), '')}';
          context.pushNamed(AppRouteBuilder.sms(phone));
        } else if (state is SmsSentWithCode) {
          // TODO убрать это когда выйдем в мвп
          final controller = context.snackbar.info(
              context, 'Код для тестирования: ${state.code}',
              position: SnackBarPosition.top);

          final phone = '7${_controller.text.replaceAll(RegExp(r'\D'), '')}';

          controller.closed.then((_) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (mounted) {
                context.push(AppRouteBuilder.sms(phone));
              }
            });
          });
        } else if (state is AuthError) {
          context.snackbar.error(context, state.message);
        }
      },
      child: Scaffold(
        appBar: const DefaultAppBar(
          showBackButton: false,
          title: 'Вход по телефону',
        ),
        body: Padding(
          padding: const EdgeInsets.symmetric(
              horizontal: UIConstants.defaultHorizontalPadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const VerticalGap(20),
              Text(
                'Контактный телефон',
                style: context.text.bodyMedium,
              ),
              const VerticalGap(8),
              PhoneInputField(controller: _controller),
              const VerticalGap(12),
              Text(
                'На указанный номер телефона будет отправлен код подтверждения',
                style: context.text.bodySmall
                    .copyWith(color: context.color.secondaryText),
              ),
              const VerticalGap(16),
              BlocBuilder<AuthCubit, AuthState>(
                builder: (context, state) {
                  return PrimaryButton(
                    text: 'Продолжить',
                    onPressed: _onContinue,
                    isLoading: state is AuthLoading,
                  );
                },
              ),
              const Spacer(),
            ],
          ),
        ),
      ),
    );
  }
}
