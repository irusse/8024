import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:neighbours/core/components/custom_gap.dart';
import 'package:neighbours/core/components/primary_button.dart';
import 'package:neighbours/core/extensions/context_ext.dart';
import 'package:neighbours/core/services/snackbar_service.dart';
import 'package:neighbours/core/components/reusable_text_field.dart';
import '../../../../core/utils/sheet_utils.dart';

class InviteNeighborsDialog extends StatelessWidget {
  final String communityCode;
  final String communityName;

  const InviteNeighborsDialog(
      {super.key, required this.communityCode, required this.communityName});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Код для приглашения', style: context.text.bodyMedium),
        const VerticalGap(4),
        ReusableTextField(
          controller: TextEditingController(text: communityCode),
          readOnly: true,
          hintText: '',
          onTap: () {
            Clipboard.setData(ClipboardData(text: communityCode)).then((_) {
              if (context.mounted) {
                context.snackbar.info(context, 'Скопировано в буфер обмена',
                    position: SnackBarPosition.top);
              }
            });
          },
        ),
        const VerticalGap(16),
        PrimaryButton(
          text: 'Далее',
          onPressed: () async {
            if (context.mounted) {
              await SheetUtils.ensureBottomSheetClosed(context);
              if (!context.mounted) return;
              context.snackbar.success(
                  context, "Вы успешно создали сообщество $communityName");
            }
          },
        ),
      ],
    );
  }
}
