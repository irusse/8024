import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/components/reusable_text_field.dart';
import '../cubits/edit_profile/edit_profile_cubit.dart';

class ProfileField extends StatelessWidget {
  final TextEditingController controller;
  final String hintText;
  final String? errorText;
  final ValueChanged<String> onChanged;

  const ProfileField({
    super.key,
    required this.controller,
    required this.hintText,
    this.errorText,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return ReusableTextField(
      controller: controller,
      hintText: hintText,
      errorText: errorText,
      onChange: onChanged,
      onTap: () {
        if (errorText != null) {
          context.read<EditProfileCubit>().clearErrors();
        }
      },
    );
  }
}
