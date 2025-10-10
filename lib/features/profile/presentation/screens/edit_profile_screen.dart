import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:neighbours/core/components/custom_gap.dart';
import 'package:neighbours/core/components/default_app_bar.dart';
import 'package:neighbours/core/components/default_page_wrapper.dart';
import 'package:neighbours/core/extensions/context_ext.dart';
import 'package:neighbours/core/components/default_dropdown.dart';
import 'package:neighbours/core/components/primary_button.dart';
import 'package:neighbours/core/components/custom_label.dart';
import 'package:neighbours/core/components/reusable_text_field.dart';
import 'package:neighbours/core/state/api_state.dart';
import '../../../../core/cubits/user/user_cubit.dart';
import '../cubits/edit_profile/edit_profile_cubit.dart';
import '../widgets/profile_avatar_picker.dart';
import '../widgets/profile_field.dart';
import '../widgets/profile_location.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  late final TextEditingController _nameController;
  late final TextEditingController _surnameController;
  late final TextEditingController _emailController;

  @override
  void initState() {
    super.initState();
    final cubit = context.read<EditProfileCubit>();
    _nameController = TextEditingController(text: cubit.state.firstName);
    _surnameController =
        TextEditingController(text: cubit.state.lastName ?? '');
    _emailController = TextEditingController(text: cubit.state.email ?? '');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _surnameController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _pickDateWithContext(BuildContext context) async {
    final now = DateTime.now();
    final cubit = context.read<EditProfileCubit>();
    final initialDate = cubit.state.birthDate ?? now;

    final picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(1900),
      lastDate: now,
      locale: const Locale('ru', 'RU'),
    );
    if (picked != null && mounted) {
      cubit.updateBirthDate(picked);
    }
  }

  String _formatBirthDate(DateTime? birthDate) {
    if (birthDate == null) return '';
    return '${birthDate.day.toString().padLeft(2, '0')}.${birthDate.month.toString().padLeft(2, '0')}.${birthDate.year}';
  }

  Future<void> _saveProfile() async {
    if (!mounted) return;

    final editProfileCubit = context.read<EditProfileCubit>();

    final userCubit = context.read<UserCubit>();
    final original = userCubit.state.user;
    final state = editProfileCubit.state;

    final updatedUser = original.copyWith(
      firstName: state.firstName,
      lastName: state.lastName,
      email: state.email,
      gender: state.gender,
      avatar: state.avatarUrl,
      birthDate: state.birthDate,
    );

    await userCubit.updateUser(
      updatedUser,
      avatarFile: state.newAvatarFile,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const DefaultAppBar(
        title: 'Редактировать',
        centerTitle: true,
        showBackButton: true,
      ),
      body: BlocListener<UserCubit, UserState>(
        listenWhen: (prev, curr) => prev.updateState != curr.updateState,
        listener: (context, state) {
          if (state.updateState.isFailure) {
            context.snackbar.error(context, state.updateState.error!);
          }
          if (state.updateState.isSuccess) {
            final updatedUser = context.read<UserCubit>().state.user;
            context
                .read<UserCubit>()
                .setUser(updatedUser);
            // Reset original user in EditProfileCubit to disable save button
            context.read<EditProfileCubit>().resetOriginalUser(updatedUser);
            context.snackbar.success(context, 'Профиль успешно обновлён');
          }
        },
        child: DefaultPageWrapper(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const VerticalGap(16),
            BlocBuilder<EditProfileCubit, EditProfileState>(
              buildWhen: (prev, curr) =>
                  prev.avatarUrl != curr.avatarUrl ||
                  prev.newAvatarFile != curr.newAvatarFile,
              builder: (context, state) {
                return ProfileAvatarPicker(
                  selectedImageFile: state.newAvatarFile,
                  currentAvatarUrl: state.avatarUrl,
                  onImagePick: () {
                    if (mounted) {
                      context.read<EditProfileCubit>().pickImageFromGallery();
                    }
                  },
                  onImageClear: () {
                    if (mounted) {
                      context.read<EditProfileCubit>().clearSelectedImage();
                    }
                  },
                );
              },
            ),
            const VerticalGap(16),
            const CustomLabel(
              text: 'Имя',
              isRequired: true,
            ),
            const VerticalGap(4),
            BlocSelector<EditProfileCubit, EditProfileState, String>(
              selector: (state) => state.firstName,
              builder: (context, firstName) {
                return BlocSelector<EditProfileCubit, EditProfileState,
                    String?>(
                  selector: (state) => state.firstNameError,
                  builder: (context, firstNameError) {
                    return ProfileField(
                      controller: _nameController,
                      hintText: 'Введите имя',
                      errorText: firstNameError,
                      onChanged: (value) {
                        context.read<EditProfileCubit>().updateFirstName(value);
                      },
                    );
                  },
                );
              },
            ),
            const VerticalGap(16),
            const CustomLabel(text: 'Фамилия'),
            const VerticalGap(4),
            BlocSelector<EditProfileCubit, EditProfileState, String?>(
              selector: (state) => state.lastName,
              builder: (context, firstName) {
                return BlocSelector<EditProfileCubit, EditProfileState,
                    String?>(
                  selector: (state) => state.lastNameError,
                  builder: (context, lastNameError) {
                    return ProfileField(
                      controller: _surnameController,
                      hintText: 'Введите фамилию',
                      errorText: lastNameError,
                      onChanged: (value) {
                        if (mounted) {
                          context
                              .read<EditProfileCubit>()
                              .updateLastName(value);
                        }
                      },
                    );
                  },
                );
              },
            ),
            const VerticalGap(16),
            const CustomLabel(text: 'Пол'),
            const VerticalGap(4),
            BlocSelector<EditProfileCubit, EditProfileState, String?>(
              selector: (state) => state.gender,
              builder: (context, gender) {
                return DefaultDropdown<String>(
                  value: gender,
                  items: const [
                    DropdownMenuItem(value: 'MALE', child: Text('Мужской')),
                    DropdownMenuItem(value: 'FEMALE', child: Text('Женский')),
                  ],
                  defaultText: 'Укажите пол',
                  onChanged: (val) {
                    if (val != null && mounted) {
                      context.read<EditProfileCubit>().updateGender(val);
                    }
                  },
                );
              },
            ),
            const VerticalGap(16),
            const CustomLabel(text: 'Дата рождения'),
            const VerticalGap(4),
            BlocSelector<EditProfileCubit, EditProfileState, DateTime?>(
              selector: (state) => state.birthDate,
              builder: (context, birthDate) {
                return Builder(
                  builder: (context) => ReusableTextField(
                    controller: TextEditingController(
                      text:
                          birthDate != null ? _formatBirthDate(birthDate) : '',
                    ),
                    hintText: 'Введите дату рождения',
                    readOnly: true,
                    onTap: () => _pickDateWithContext(context),
                  ),
                );
              },
            ),
            const VerticalGap(16),
            const CustomLabel(text: 'Email'),
            const VerticalGap(4),
            BlocSelector<EditProfileCubit, EditProfileState, String?>(
              selector: (state) => state.email,
              builder: (context, email) {
                return BlocSelector<EditProfileCubit, EditProfileState,
                    String?>(
                  selector: (state) => state.emailError,
                  builder: (context, emailError) {
                    return ReusableTextField(
                      controller: _emailController,
                      hintText: 'Введите почту',
                      errorText: emailError,
                      keyboardType: TextInputType.emailAddress,
                      onChange: (value) {
                        if (mounted) {
                          context.read<EditProfileCubit>().updateEmail(value);
                        }
                      },
                      onTap: () {
                        if (emailError != null && mounted) {
                          context.read<EditProfileCubit>().clearErrors();
                        }
                      },
                    );
                  },
                );
              },
            ),
            const VerticalGap(16),
            const CustomLabel(text: 'Местоположение'),
            const VerticalGap(8),
            const ProfileLocation(),
            const VerticalGap(24),
            const Spacer(),
            BlocBuilder<EditProfileCubit, EditProfileState>(
              builder: (context, state) {
                final isLoading = context.select<UserCubit, bool>(
                  (cubit) => cubit.state.updateState.isLoading,
                );

                final hasValidationErrors = state.firstNameError != null ||
                    state.lastNameError != null ||
                    state.emailError != null;

                final hasChanges =
                    context.read<EditProfileCubit>().hasChanges();

                return PrimaryButton(
                  text: 'Сохранить изменения',
                  isLoading: isLoading,
                  isEnabled: hasChanges && !hasValidationErrors,
                  onPressed: _saveProfile,
                );
              },
            ),
            const VerticalGap(24),
          ],
        ),
      ),
    );
  }
}
