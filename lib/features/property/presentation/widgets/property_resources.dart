import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:neighbours/core/components/default_loading_overlay.dart';
import 'package:neighbours/core/extensions/context_ext.dart';
import 'package:neighbours/core/state/api_state.dart';
import 'package:neighbours/core/components/error_with_try_btn.dart';
import 'package:neighbours/features/property/presentation/widgets/resource_item.dart';

import '../../../../core/components/custom_button.dart';
import '../../../../core/components/custom_gap.dart';
import '../../../../core/router/app_routes.dart';
import '../cubits/resources/resources_cubit.dart';

class PropertyResources extends StatelessWidget {
  final bool isUserProperty;
  final int propertyId;

  const PropertyResources(
      {super.key, required this.propertyId, required this.isUserProperty});

  int calculateCrossAxisCount(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    if (screenWidth >= 1200) return 4;
    if (screenWidth >= 800) return 3;
    return 2;
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ResourcesCubit, ResourcesState>(
      listener: (BuildContext context, ResourcesState state) {
        if (state.deleteState.isSuccess) {
          context.snackbar.success(context, 'Ресурс успешно удален');
        }
      },
      builder: (context, state) {
        if (state.fetchState.isLoading) {
          return const DefaultLoadingOverlay();
        }

        if (state.fetchState.isFailure) {
          return ErrorWithTryBtn(
              error: state.error!,
              onErrorClick: () => context
                  .read<ResourcesCubit>()
                  .fetchResourcesByPropertyId(propertyId));
        }

        final resources = state.resources;

        return Column(
          children: [
            const VerticalGap(16),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: calculateCrossAxisCount(context),
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: 0.75,
              ),
              itemCount: resources.length,
              itemBuilder: (context, index) => ResourceItem(
                isUserProperty: isUserProperty,
                resourceEntity: resources[index],
              ),
            ),
            if (isUserProperty) ...[
              const VerticalGap(16),
              Center(
                child: CustomButton(
                  onPressed: () => context.push(
                    AppRouteBuilder.resourceForm(propertyId),
                  ),
                  height: 36,
                  width: 36,
                  style: BoxDecoration(
                    color: context.color.primary,
                    shape: BoxShape.circle,
                  ),
                  icon: const Icon(Icons.add, color: Colors.white),
                ),
              ),
            ]
          ],
        );
      },
    );
  }
}
