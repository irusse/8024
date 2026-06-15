import 'package:flutter/material.dart';
import 'package:neighbours/core/components/custom_gap.dart';
import 'package:neighbours/core/components/primary_button.dart';
import 'package:neighbours/core/extensions/context_ext.dart';
import 'package:neighbours/core/services/clipboard_service.dart';
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
          onTap: () => ClipboardService.copyToClipboard(
              context: context, text: communityCode),
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
