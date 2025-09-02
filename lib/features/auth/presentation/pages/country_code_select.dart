import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:neighbours/core/components/default_app_bar.dart';
import 'package:neighbours/features/auth/presentation/resources/country_specs.dart';
import 'package:neighbours/features/auth/presentation/widgets/country_code_item.dart';

import '../cubits/auth/auth_cubit.dart';

class CountryCodeSelect extends StatelessWidget {
  const CountryCodeSelect({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar:
          const DefaultAppBar(showBackButton: true, title: 'Выберите страну'),
      body: ListView.builder(
        itemCount: CountrySpecs.all.length,
        itemBuilder: (context, index) => CountryCodeItem(
          onItemClick: () {

            final selectedCountry = CountrySpecs.all[index];
            context.read<AuthCubit>().onCountryChanged(selectedCountry);
            context.pop();
          },
          countryPhoneSpec: CountrySpecs.all[index],
        ),
      ),
    );
  }
}
