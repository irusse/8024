import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:neighbours/core/components/custom_gap.dart';
import 'package:neighbours/core/components/primary_button.dart';
import 'package:neighbours/core/cubits/user/user_cubit.dart';
import 'package:neighbours/core/cubits/user_location/user_location_cubit.dart';
import 'package:neighbours/core/di/injection.dart';
import 'package:neighbours/features/community/presentation/cubits/community/community_cubit.dart';
import 'package:neighbours/features/home/presentation/widgets/join_community_dialog.dart';
import 'package:neighbours/features/home/presentation/widgets/create_community_dialog.dart';
import '../../../../core/components/bottom_sheet_dialog.dart';
import '../../../../core/utils/sheet_utils.dart';
import '../cubits/community_access_form/community_access_cubit.dart';

class NoCommunitiesDialog extends StatelessWidget {
  final VoidCallback onDataFetchRequired;

  const NoCommunitiesDialog({
    super.key,
    required this.onDataFetchRequired,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        PrimaryButton(
          text: 'Вступить',
          onPressed: () => _openBottomSheet(
            context,
            title: 'Вступить в сообщество',
            child:
                JoinCommunityDialog(onDataFetchRequired: onDataFetchRequired),
          ),
        ),
        const VerticalGap(8),
        PrimaryButton(
          text: 'Создать',
          onPressed: () => _openBottomSheet(
            context,
            title: 'Рядом с вами нет сообществ.\nХотите создать ?',
            child:
                CreateCommunityDialog(onDataFetchRequired: onDataFetchRequired),
          ),
        ),
      ],
    );
  }

  Future<void> _openBottomSheet(
    BuildContext context, {
    required String title,
    required Widget child,
  }) async {
    final hostContext = Navigator.of(context).overlay?.context ?? context;

    await SheetUtils.ensureBottomSheetClosed(context);
    if (!hostContext.mounted) return;
    showBaseBottomSheet(
      context: hostContext,
      title: title,
      isDismissible: false,
      child: MultiBlocProvider(
        providers: [
          BlocProvider(
            create: (_) => getIt<CommunityAccessCubit>(),
          ),
          BlocProvider.value(
            value: getIt<UserLocationCubit>(),
          ),
          BlocProvider.value(
            value: getIt<UserCubit>(),
          ),
          BlocProvider.value(
            value: getIt<CommunityCubit>(),
          ),
        ],
        child: child,
      ),
    );
  }
}
