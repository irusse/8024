import 'package:flutter/material.dart';
import 'package:neighbours/core/extensions/context_ext.dart';
import 'package:neighbours/features/auth/presentation/ui-models/country_phone_spec.dart';
import '../../../../core/components/custom_gap.dart';
import '../../../../core/constants/ui_constants.dart';

class CountryCodeItem extends StatelessWidget {
  final VoidCallback onItemClick;
  final CountryPhoneSpec countryPhoneSpec;

  const CountryCodeItem({
    super.key,
    required this.countryPhoneSpec,
    required this.onItemClick,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onItemClick,
      child: Container(
        color: context.color.background,
        padding: const EdgeInsets.symmetric(
          horizontal: UIConstants.defaultHorizontalPadding,
        ),
        height: 48,
        child: Row(
          children: [
            Text(countryPhoneSpec.flag, style: const TextStyle(fontSize: 20)),
            const HorizontalGap(8),
            Text(
              countryPhoneSpec.name,
              style: context.text.bodyLarge.copyWith(),
            ),
            const Spacer(),
            Text(
              countryPhoneSpec.dialCode,
              style: context.text.bodyLarge.copyWith(
                fontWeight: FontWeight.w500,
                color: context.color.primary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
