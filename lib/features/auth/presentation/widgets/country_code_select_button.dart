import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:neighbours/core/extensions/context_ext.dart';
import 'package:neighbours/core/router/app_routes.dart';

import '../../../../core/components/custom_gap.dart';
import '../../../../core/constants/ui_constants.dart';
import '../ui-models/country_phone_spec.dart';

class CountrySelectButton extends StatelessWidget {
  final CountryPhoneSpec selectedCountry;

  const CountrySelectButton({super.key, required this.selectedCountry});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => context.pushNamed(AppRoutePath.countryCodeSelect),
      child: Container(
        height: 48,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: UIConstants.getDefaultBorder(context, null),
        ),
        child: Row(
          children: [
            Text(selectedCountry.flag, style: const TextStyle(fontSize: 16)),
            const HorizontalGap(8),
            Text(
              selectedCountry.name,
              style: context.text.bodyMedium.copyWith(
                fontWeight: FontWeight.w500,
              ),
            ),
            const Spacer(),
            Icon(
              Icons.arrow_forward_ios_rounded,
              color: context.color.secondaryText,
              size: 16,
            ),
          ],
        ),
      ),
    );
  }
}