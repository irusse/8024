import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geocoding/geocoding.dart';
import 'package:neighbours/core/components/custom_gap.dart';
import 'package:neighbours/core/components/custom_svg.dart';
import 'package:neighbours/core/cubits/user_location/user_location_cubit.dart';
import 'package:neighbours/core/extensions/context_ext.dart';
import 'package:neighbours/core/extensions/placemark_ext.dart';
import 'package:neighbours/core/services/map_service.dart';
import '../../../../core/constants/assets.dart';
import 'package:neighbours/core/components/primary_button.dart';

import '../cubits/auth_location/auth_location_cubit.dart';

class AuthAddressDialog extends StatefulWidget {
  const AuthAddressDialog({
    required this.onSuccess,
    super.key,
  });

  final Function(LatLng, Placemark) onSuccess;

  @override
  State<AuthAddressDialog> createState() => _AuthAddressDialogState();
}

class _AuthAddressDialogState extends State<AuthAddressDialog> {
  @override
  void initState() {
    context.read<UserLocationCubit>().getPosition();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CustomSvg(
                asset: Assets.icons.location, color: context.color.primary),
            const HorizontalGap(16),
            Expanded(child: BlocBuilder<UserLocationCubit, UserLocationState>(
              builder: (context, state) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      state.maybeWhen(
                        initial: () => 'Определение местоположения...',
                        loading: () => 'Определение местоположения...',
                        locationReceived: (coordinates, placeMark) =>
                            placeMark.title,
                        error: (message) => message,
                        orElse: () => 'Не удалось определить местоположение',
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: context.text.bodyLarge
                          .copyWith(fontWeight: FontWeight.w500),
                    ),
                    const VerticalGap(2),
                    Text(
                      state.maybeWhen(
                          loading: () => '',
                          locationReceived: (latLng, placeMark) =>
                              placeMark.subtitle,
                          error: (message) => message,
                          orElse: () => 'Не удалось определить местоположение'),
                      style: context.text.labelLarge.copyWith(
                        color: context.color.secondaryText,
                      ),
                    ),
                  ],
                );
              },
            )),
          ],
        ),
        const VerticalGap(16),
        BlocBuilder<UserLocationCubit, UserLocationState>(
          builder: (context, state) {
            final sending = context.select<AuthLocationCubit, bool>((cubit) =>
                cubit.state
                    .maybeWhen(orElse: () => false, sending: () => true));
            final enabled = state.maybeWhen(
              orElse: () => false,
              locationReceived: (_, __) => true,
            );
            final loading = state.maybeWhen(
              orElse: () => false,
              loading: () => true,
            );
            return PrimaryButton(
                verticalPadding: 12,
                text: 'Подтвердить',
                isEnabled: enabled,
                isLoading: loading || sending,
                onPressed: () async {
                  final locationState = context.read<UserLocationCubit>().state;
                  await locationState.maybeWhen(
                    locationReceived: (latLng, placeMark) async {
                      await context
                          .read<AuthLocationCubit>()
                          .submitAddress(latLng, placeMark);
                      widget.onSuccess(latLng, placeMark);
                    },
                    orElse: () async {},
                  );
                });
          },
        ),
      ],
    );
  }
}
