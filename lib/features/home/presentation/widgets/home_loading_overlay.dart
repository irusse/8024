import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:neighbours/core/components/default_loading_overlay.dart';
import 'package:neighbours/core/state/api_state.dart';
import 'package:neighbours/features/property/presentation/cubits/properties/properties_cubit.dart';
import '../../../../core/cubits/user/user_cubit.dart';
import '../cubits/home/home_cubit.dart';

class HomeLoadingOverlay extends StatelessWidget {
  const HomeLoadingOverlay({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final homeState = context.watch<HomeCubit>().state;
    final propertiesState = context.watch<PropertiesCubit>().state;
    final userState = context.watch<UserCubit>().state;

    final isPropertiesLoading = propertiesState.fetchState.isLoading;
    final isUserLoading = userState.fetchState.isLoading;
    final isHomeLoading = homeState is Loading;
    final isAnyLoading = isPropertiesLoading || isUserLoading || isHomeLoading;
    return !isAnyLoading
        ? const SizedBox.shrink()
        : const DefaultLoadingOverlay();
  }
}
