import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:neighbours/core/extensions/context_ext.dart';
import 'package:neighbours/core/extensions/placemark_ext.dart';

import '../../../../core/components/custom_gap.dart';
import '../../../../core/cubits/user_location/user_location_cubit.dart';

class ProfileLocation extends StatelessWidget {
  const ProfileLocation({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<UserLocationCubit, UserLocationState>(
      builder: (context, state) {
        return state.maybeWhen(
          locationReceived: (_, placemark) => Row(
            children: [
              Icon(
                Icons.location_on,
                color: context.color.primary,
                size: 24,
              ),
              const HorizontalGap(8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      placemark.title,
                      style: context.text.bodyLarge,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      placemark.subtitle,
                      style: context.text.labelLarge.copyWith(
                        color: context.color.secondaryText,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          orElse: () => const SizedBox.shrink(),
        );
      },
    );
  }
}
