import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:neighbours/core/components/custom_gap.dart';
import 'package:neighbours/core/extensions/context_ext.dart';
import 'package:neighbours/core/components/primary_button.dart';
import 'package:neighbours/core/components/custom_label.dart';
import 'package:neighbours/core/components/reusable_text_field.dart';
import 'package:neighbours/core/services/snackbar_service.dart';
import 'package:neighbours/core/state/api_state.dart';
import 'package:neighbours/features/profile/presentation/cubits/profile_create/profile_create_cubit.dart';
import '../../../../core/cubits/user/user_cubit.dart';
import 'dart:io';

class ProfileDialog extends StatefulWidget {
  final VoidCallback onSuccess;

  const ProfileDialog({super.key, required this.onSuccess});

  @override
  State<ProfileDialog> createState() => _ProfileDialogState();
}

class _ProfileDialogState extends State<ProfileDialog> {
  final _nameController = TextEditingController();
  final _surnameController = TextEditingController();
  final _emailController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _surnameController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isSubmitting = context
        .select<UserCubit, bool>((cubit) => cubit.state.createState.isLoading);
    final image =
        context.select((ProfileCreateCubit cubit) => cubit.state.image);
    final cubit = context.read<ProfileCreateCubit>();
    return BlocListener<UserCubit, UserState>(
      listener: (context, state) {
        state.createState.handleApiState(
            onSuccess: () => widget.onSuccess(),
            onError: (error) => context.snackbar
                .error(context, error, position: SnackBarPosition.top));
      },
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const VerticalGap(8),
            Center(
              child: GestureDetector(
                onTap: () =>
                    context.read<ProfileCreateCubit>().pickImageFromGallery(),
                child: image == null
                    ? Container(
                        width: 72,
                        height: 72,
                        decoration: BoxDecoration(
                          color: context.color.tertiary,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.camera_alt_outlined,
                          color: Colors.white,
                        ),
                      )
                    : Stack(
                        alignment: Alignment.topRight,
                        children: [
                          ClipOval(
                            child: Image.file(
                              File(image.path),
                              width: 72,
                              height: 72,
                              fit: BoxFit.cover,
                            ),
                          ),
                          GestureDetector(
                            onTap: () => cubit.removeImage(),
                            child: Container(
                              decoration: BoxDecoration(
                                color: context.color.tertiary,
                                shape: BoxShape.circle,
                              ),
                              padding: const EdgeInsets.all(2),
                              child: Icon(Icons.close,
                                  size: 16, color: context.color.basicRed),
                            ),
                          ),
                        ],
                      ),
              ),
            ),
            const VerticalGap(12),
            const CustomLabel(
              text: 'Имя',
              isRequired: true,
            ),
            const VerticalGap(4),
            BlocBuilder<ProfileCreateCubit, ProfileCreateState>(
                buildWhen: (old, curr) =>
                    old.nameError != curr.nameError || old.name != curr.name,
                builder: (context, state) {
                  return ReusableTextField(
                    controller: _nameController,
                    hintText: 'Введите имя',
                    errorText: state.nameError,
                    onChange: cubit.onNameChanged,
                  );
                }),
            const VerticalGap(8),
            const CustomLabel(
              text: 'Фамилия',
            ),
            const VerticalGap(4),
            BlocBuilder<ProfileCreateCubit, ProfileCreateState>(
                buildWhen: (old, curr) =>
                    old.surnameError != curr.surnameError ||
                    old.surname != curr.surname,
                builder: (context, state) {
                  return ReusableTextField(
                    hintText: 'Введите фамилию',
                    controller: _surnameController,
                    errorText: state.surnameError,
                    onChange: cubit.onSurnameChanged,
                  );
                }),
            const VerticalGap(8),
            const CustomLabel(text: 'Email'),
            const VerticalGap(4),
            BlocBuilder<ProfileCreateCubit, ProfileCreateState>(
                buildWhen: (old, curr) =>
                    old.emailError != curr.emailError ||
                    old.email != curr.email,
                builder: (context, state) {
                  return ReusableTextField(
                    hintText: 'Введите почту',
                    errorText: state.emailError,
                    keyboardType: TextInputType.emailAddress,
                    controller: _emailController,
                    onChange: cubit.onEmailChanged,
                  );
                }),
            const VerticalGap(16),
            BlocBuilder<ProfileCreateCubit, ProfileCreateState>(
              builder: (context, state) {
                return PrimaryButton(
                  text: isSubmitting ? 'Ожидайте' : 'Добавить',
                  isEnabled:
                      context.read<ProfileCreateCubit>().validateAllFields(),
                  isLoading: isSubmitting,
                  onPressed: () async {
                    await context.read<UserCubit>().createProfile(
                        name: state.name,
                        surname: state.surname,
                        email: state.email,
                        image: state.image);
                  },
                );
              },
            )
          ],
        ),
      ),
    );
  }
}
