import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:neighbours/core/components/custom_button.dart';
import 'package:neighbours/core/extensions/context_ext.dart';

import '../constants/ui_constants.dart';
import 'custom_gap.dart';

class DefaultAppBar extends StatelessWidget implements PreferredSizeWidget {
  final VoidCallback? onBackClick;
  final bool showBackButton;
  final String? title;
  final Widget? titleWidget;
  final List<Widget> actions;

  final double height;
  final bool centerTitle; // Новый параметр

  const DefaultAppBar({
    super.key,
    this.onBackClick,
    required this.showBackButton,
    this.title,
    this.height = 56,
    this.titleWidget,
    this.actions = const [],
    this.centerTitle = false, // Значение по умолчанию
  });

  @override
  Size get preferredSize => Size.fromHeight(height);

  @override
  Widget build(BuildContext context) {
    return PreferredSize(
      preferredSize: Size.fromHeight(height),
      child: SafeArea(
        child: Container(
          height: height,
          padding: const EdgeInsets.symmetric(
              horizontal: UIConstants.defaultHorizontalPadding, vertical: 12),
          child: Stack(
            alignment: Alignment.center,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  _showLeading(context),
                  const HorizontalGap(12),
                  if (!centerTitle) ...[
                    if (titleWidget != null) titleWidget!,
                    if (title != null && titleWidget == null)
                      Expanded(
                        child: AutoSizeText(
                          title!,
                          style: context.text.titleSmall,
                          textAlign: TextAlign.start,
                          maxLines: 1,
                          minFontSize: context.text.bodyLarge.fontSize!,
                          overflow: TextOverflow.ellipsis,
                        ),
                      )
                  ],
                  if (actions.isNotEmpty)
                    Expanded(
                      child: Row(
                        children: [const Spacer(), ...actions],
                      ),
                    ),
                ],
              ),
              if (centerTitle)
                Center(
                  child: titleWidget ??
                      (title != null
                          ? AutoSizeText(
                              title!,
                              style: context.text.titleSmall,
                              textAlign: TextAlign.start,
                              maxLines: 1,
                              minFontSize: context.text.bodyLarge.fontSize!,
                              overflow: TextOverflow.ellipsis,
                            )
                          : const SizedBox()),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _showLeading(BuildContext context) {
    if (showBackButton) {
      return CustomButton(
        onPressed: () => onBackClick != null
            ? onBackClick!()
            : Navigator.of(context).maybePop(),
        icon: Icon(
          Icons.arrow_back_rounded,
          color: context.color.secondaryText,
        ),
      );
    } else {
      return Container();
    }
  }
}
