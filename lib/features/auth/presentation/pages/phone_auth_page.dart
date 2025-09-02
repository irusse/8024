import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:neighbours/core/components/custom_gap.dart';
import 'package:neighbours/core/components/default_app_bar.dart';
import 'package:neighbours/core/extensions/context_ext.dart';
import 'package:neighbours/core/state/api_state.dart';
import 'package:neighbours/features/auth/presentation/widgets/country_code_select_button.dart';
import 'package:neighbours/core/components/primary_button.dart';
import 'package:neighbours/core/router/app_routes.dart';
import 'package:neighbours/core/services/snackbar_service.dart';
import 'package:neighbours/features/auth/presentation/widgets/phone_number_text_field.dart';
import '../../../../core/constants/ui_constants.dart';
import '../cubits/auth/auth_cubit.dart';

class PhoneAuthPage extends StatefulWidget {
  const PhoneAuthPage({super.key});

  @override
  State<PhoneAuthPage> createState() => _PhoneAuthPageState();
}

class _PhoneAuthPageState extends State<PhoneAuthPage> {
  @override
  Widget build(BuildContext context) {
    final isValid = context.select<AuthCubit, bool>((c) => c.state.isValid);
    return BlocListener<AuthCubit, AuthState>(
      listenWhen: (prev, curr) => prev.loginState != curr.loginState,
      listener: (context, state) {
        if (state.loginState.isSuccess) {
          final phone = '7${state.digits}';
          if (state.smsCode == null) {
            context.push(AppRouteBuilder.sms(phone));
            return;
          }
          // TODO убрать это когда выйдем в мвп
          final controller = context.snackbar.info(
              context, 'Код для тестирования: ${state.smsCode}',
              position: SnackBarPosition.top);

          controller.closed.then((_) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (mounted) {
                context.push(AppRouteBuilder.sms(phone));
              }
            });
          });
        }
        if (state.loginState.isFailure) {
          context.snackbar.error(context, state.loginState.error!);
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
              BlocBuilder<AuthCubit, AuthState>(
                builder: (context, state) {
                  return Column(
                    children: [
                      CountrySelectButton(selectedCountry: state.country),
                      const VerticalGap(16),
                      PhoneNumberTextField(country: state.country),
                    ],
                  );
                },
              ),
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
                    onPressed: () => context.read<AuthCubit>().phoneLogin(),
                    isEnabled: isValid,
                    isLoading: state.loginState.isLoading,
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
