import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:neighbours/core/cubits/user_location/user_location_cubit.dart';
import 'package:neighbours/core/di/injection.dart';
import 'package:neighbours/core/extensions/context_ext.dart';
import 'package:neighbours/features/home/presentation/cubits/auth_location/auth_location_cubit.dart';
import 'package:neighbours/features/home/presentation/pages/home.dart';
import 'package:neighbours/features/home/presentation/widgets/add_event_dialog.dart';
import 'package:neighbours/features/home/presentation/widgets/auth_address_dialog.dart';
import 'package:neighbours/features/home/presentation/widgets/no_communities_dialog.dart';
import 'package:neighbours/features/home/presentation/widgets/profile_dialog.dart';
import 'package:neighbours/features/home/presentation/widgets/add_property_dialog.dart';
import 'package:neighbours/core/components/bottom_sheet_dialog.dart';
import 'package:neighbours/core/cubits/user/user_cubit.dart';
import 'package:neighbours/features/property/presentation/cubits/properties/properties_cubit.dart';
import 'package:neighbours/features/property/presentation/cubits/property_form/property_form_cubit.dart';

import '../../../../core/utils/sheet_utils.dart';
import '../cubits/home/home_cubit.dart';
import '../cubits/profile_create/profile_create_cubit.dart';

mixin StepSheetManager<T extends StatefulWidget> on State<Home> {
  Future<void> showStepSheet(
    BuildContext context,
    HomeState state, {
    required VoidCallback onDataFetchRequired,
  }) async {
    switch (state) {
      case ShowAddressStep():
        return _buildStepSheet(
          context,
          title: 'Определить местоположение',
          enableDrag: false,
          isDismissible: false,
          child: MultiBlocProvider(
            providers: [
              BlocProvider(
                create: (_) => getIt<AuthLocationCubit>(),
              ),
              BlocProvider.value(
                value: getIt<UserLocationCubit>(),
              ),
            ],
            child: AuthAddressDialog(
              onSuccess: (latLng, placemark) {
                context.read<HomeCubit>()
                  ..incrementStep()
                  ..goToUserInfoStep();
              },
            ),
          ),
        );

      case ShowUserInfoStep():
        return _buildStepSheet(
          context,
          title: 'Как вас зовут?',
          isDismissible: false,
          child: MultiBlocProvider(
            providers: [
              BlocProvider(create: (_) => getIt<ProfileCreateCubit>()),
              BlocProvider.value(value: getIt<UserCubit>()),
            ],
            child: ProfileDialog(
              onSuccess: () {
                context.read<HomeCubit>()
                  ..incrementStep()
                  ..goToAddPropertyStep();
              },
            ),
          ),
        );

      case ShowAddPropertyStep():
        await _buildStepSheet(context,
            title: 'Добавьте объект недвижимости',
            isDismissible: false,
            child: MultiBlocProvider(
              providers: [
                BlocProvider.value(
                  value: context.read<PropertyFormCubit>(),
                ),
                BlocProvider.value(
                  value: getIt<PropertiesCubit>(),
                ),
                BlocProvider.value(
                  value: getIt<UserLocationCubit>(),
                ),
              ],
              child: AddPropertyDialog(
                isFirstProperty: context.read<HomeCubit>().isFirstProperty(),
                onSuccess: () async {
                  // Увеличиваем шаг только один раз при успешном добавлении
                  context.read<HomeCubit>().incrementStep();
                  context.read<PropertyFormCubit>().reset();
                  await SheetUtils.ensureBottomSheetClosed(context);
                  if (context.mounted) {
                    context.snackbar
                        .success(context, 'Объект успешно добавлен!');
                  }
                  // Устанавливаем состояние Idle после закрытия bottom sheet
                  if (context.mounted) {
                    context.read<HomeCubit>().setIdle();
                  }
                },
                onSetCoordinatesClick: () =>
                    context.read<HomeCubit>().showSetCoordinates(),
              ),
            ));
        return;
      case ShowSetCoordinates():
        return await SheetUtils.ensureBottomSheetClosed(context);
      case ShowAddEvent():
        return _buildStepSheet(
          context,
          title: 'Добавить',
          isDismissible: true,
          child: const AddEventDialog(),
        );
      case ShowNoActiveCommunities():
        return _buildStepSheet(
          context,
          title: 'У вас нет Активных сообществ',
          isDismissible: true,
          child: NoCommunitiesDialog(onDataFetchRequired: onDataFetchRequired),
        );
      case Idle():
        return;
      default:
        return;
    }
  }

  Future<R?> _buildStepSheet<R>(
    BuildContext context, {
    required Widget child,
    required String title,
    bool isDismissible = true,
    bool enableDrag = true,
  }) async {
    await SheetUtils.ensureBottomSheetClosed(context);
    if (context.mounted) {
      return showBaseBottomSheet<R>(
        context: context,
        title: title,
        isDismissible: isDismissible,
        enableDrag: enableDrag,
        child: child,
      );
    }
    return null;
  }
}
