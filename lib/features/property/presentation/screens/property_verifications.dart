import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:neighbours/core/components/custom_gap.dart';
import 'package:neighbours/core/components/default_app_bar.dart';
import 'package:neighbours/core/components/default_loading_overlay.dart';
import 'package:neighbours/core/extensions/context_ext.dart';
import 'package:neighbours/core/state/api_state.dart';
import 'package:neighbours/features/community/presentation/widgets/error_with_try_btn.dart';
import 'package:neighbours/features/profile/presentation/cubits/user_verified_properties/user_verified_properties_cubit.dart';
import 'package:neighbours/features/profile/presentation/widgets/verified_property_item.dart';

class PropertyVerifications extends StatefulWidget {
  const PropertyVerifications({super.key});

  @override
  State<PropertyVerifications> createState() => _PropertyVerificationsState();
}

class _PropertyVerificationsState extends State<PropertyVerifications> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<UserVerifiedPropertiesCubit>().fetchUserVerifications();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const DefaultAppBar(
        showBackButton: true,
        title: 'Мои подтверждения',
      ),
      body: BlocConsumer<UserVerifiedPropertiesCubit,
          UserVerifiedPropertiesState>(
        listener: (context, state) {
          state.fetchState.maybeWhen(
            failure: (message) {
              context.snackbar.error(context, message);
            },
            orElse: () {},
          );
        },
        builder: (context, state) {
          return Stack(
            children: [
              ListView.separated(
                padding: const EdgeInsets.all(16),
                itemCount: state.verifications.length,
                itemBuilder: (context, index) {
                  final verification = state.verifications[index];
                  return VerifiedPropertyItem(entity: verification);
                },
                separatorBuilder: (context, index) => const VerticalGap(8),
              ),
              if (state.fetchState.isLoading)
                const DefaultLoadingOverlay(
                  transparent: true,
                ),
              if (state.fetchState.isFailure)
                ErrorWithTryBtn(
                    error: state.fetchState.error!,
                    onErrorClick: () => context
                        .read<UserVerifiedPropertiesCubit>()
                        .fetchUserVerifications())
            ],
          );
        },
      ),
    );
  }
}
