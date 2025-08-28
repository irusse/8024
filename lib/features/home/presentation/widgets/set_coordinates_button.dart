import 'package:flutter/material.dart';
import 'package:neighbours/core/constants/ui_constants.dart';
import 'package:neighbours/core/extensions/context_ext.dart';

class SetCoordinatesButton extends StatelessWidget {
  final String? text;
  final VoidCallback onClick;

  const SetCoordinatesButton({super.key, required this.onClick, this.text});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
        onTap: onClick,
        child: Container(
          width: double.infinity,
          padding: UIConstants.defaultTextFieldPadding,
          alignment: Alignment.centerLeft,
          height: UIConstants.defaultTextFieldHeight,
          decoration: BoxDecoration(
            border: UIConstants.getDefaultBorder(context, false),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            text ?? 'Нажмите, чтобы выбрать на карте',
            style: context.text.bodyMedium.copyWith(
                color: text != null
                    ? context.color.primaryText
                    : context.color.secondaryText),
          ),
        ));
  }
}
