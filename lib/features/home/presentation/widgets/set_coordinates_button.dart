import 'package:flutter/material.dart';
import 'package:neighbours/core/components/custom_button.dart';
import 'package:neighbours/core/components/custom_gap.dart';
import 'package:neighbours/core/components/custom_outlined_button.dart';
import 'package:neighbours/core/constants/ui_constants.dart';
import 'package:neighbours/core/extensions/context_ext.dart';

class SetCoordinatesButton extends StatelessWidget {
  final String? text;
  final VoidCallback onClick;
  final VoidCallback onClear;

  const SetCoordinatesButton(
      {super.key, required this.onClick, required this.onClear, this.text});

  @override
  Widget build(BuildContext context) {
    final hasCoordinates = text != null;

    return Container(
      width: double.infinity,
      padding: hasCoordinates
          ? UIConstants.defaultTextFieldPadding
          : const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      alignment: hasCoordinates ? Alignment.centerLeft : Alignment.center,
      height: hasCoordinates ? UIConstants.defaultTextFieldHeight : null,
      decoration: BoxDecoration(
        border: UIConstants.getDefaultBorder(context, false),
        borderRadius: BorderRadius.circular(8),
      ),
      child: !hasCoordinates
          ? CustomOutlinedButton(
              onPressed: onClick,
              text: 'Выберите координаты',
              iconData: Icons.location_on_outlined,
            )
          : GestureDetector(
              onTap: onClick,
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      text!,
                      style: context.text.bodyMedium.copyWith(
                        overflow: TextOverflow.ellipsis,
                        color: context.color.primaryText,
                      ),
                    ),
                  ),
                  const HorizontalGap(8),
                  CustomButton(
                    onPressed: onClear,
                    icon: Icon(
                      size: 18,
                      Icons.close,
                      color: context.color.basicRed,
                    ),
                  )
                ],
              ),
            ),
    );
  }
}
