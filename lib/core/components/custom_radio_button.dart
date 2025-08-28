import 'package:flutter/material.dart';
import 'package:neighbours/core/constants/ui_constants.dart';
import 'package:neighbours/core/extensions/context_ext.dart';

import 'custom_gap.dart';

class CustomRadioButton extends StatelessWidget {
  final String title;
  final String? description;
  final Function(dynamic) onTap;
  final dynamic value;

  /// is Radio button enabled. If Radio butonn is not enabled then we cannot click on it
  final bool isEnabled;

  /// is Radio button active.
  final bool isActive;
  final Widget? child;
  final TextStyle titleTextStyle;
  final EdgeInsets buttonPadding;
  final Color? inActiveColor;

  const CustomRadioButton(
      {Key? key,
      required this.title,
      required this.onTap,
      required this.value,
      required this.isActive,
      required this.titleTextStyle,
      this.isEnabled = true,
      this.buttonPadding = const EdgeInsets.symmetric(vertical: 8),
      this.child,
      this.inActiveColor,
      this.description})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      splashColor: Colors.transparent,
      highlightColor: Colors.transparent,
      onTap: () {
        if (isEnabled) {
          onTap(value);
        }
      },
      child: Container(
        padding: buttonPadding,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _circle(context, inActiveColor),
            const HorizontalGap(12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: titleTextStyle.copyWith(
                            color: isEnabled
                                ? context.color.primaryText
                                : context.color.tertiary),
                      ),
                      if (description != null)
                        Column(
                          children: [
                            const VerticalGap(4),
                            Text(
                              description!,
                              maxLines: 3,
                              style: context.text.bodySmall.copyWith(
                                  color: isEnabled
                                      ? context.color.secondaryText
                                      : context.color.tertiary),
                            ),
                          ],
                        )
                    ],
                  ),
                  AnimatedSwitcher(
                      switchInCurve: Curves.easeIn,
                      switchOutCurve: Curves.easeIn,
                      duration: UIConstants.defaultAnimationDuration,
                      transitionBuilder: (child, animation) {
                        return SlideTransition(
                          position: Tween<Offset>(
                            begin: const Offset(0, -.3),
                            end: Offset.zero,
                          ).animate(animation),
                          child: FadeTransition(
                            opacity: animation,
                            child: child,
                          ),
                        );
                      },
                      child: // Show child if radio button is active and has a child
                          child != null && isActive ? child : null),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _circle(BuildContext context, Color? inActiveColor) {
    return AnimatedContainer(
      width: 24,
      height: 24,
      decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(
              width: 2,
              color: isActive
                  ? context.color.primary
                  : inActiveColor ?? context.color.secondary)),
      padding: const EdgeInsets.all(4),
      duration: UIConstants.defaultAnimationDuration,
      child: AnimatedContainer(
        duration: UIConstants.defaultAnimationDuration,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: isActive ? context.color.primary : null,
        ),
      ),
    );
  }
}
