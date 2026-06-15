import 'package:flutter/material.dart';
import 'package:neighbours/core/components/custom_gap.dart';
import 'package:neighbours/core/components/drag_handle.dart';
import 'package:neighbours/core/extensions/context_ext.dart';

class BaseBottomSheetDialog extends StatelessWidget {
  final Widget child;
  final double? height;
  final Color? backgroundColor;
  final BorderRadius? borderRadius;
  final EdgeInsets? padding;
  final bool showDragHandle;
  final bool isDismissible;
  final bool enableDrag;
  final String? title;

  const BaseBottomSheetDialog({
    Key? key,
    required this.child,
    this.height,
    this.backgroundColor,
    this.borderRadius,
    this.padding,
    this.showDragHandle = true,
    this.isDismissible = true,
    this.enableDrag = true,
    this.title,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      padding: (padding ?? const EdgeInsets.all(16)) +
          MediaQuery.of(context).viewInsets,
      decoration: BoxDecoration(
        color: backgroundColor ?? context.color.background,
        borderRadius: borderRadius ??
            const BorderRadius.vertical(
              top: Radius.circular(20),
            ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (showDragHandle) const DragHandle(),
          if (title != null) ...[
            Container(
              margin: const EdgeInsets.only(top: 16),
              child: Center(
                child: Text(
                  title!,
                  style: context.text.titleSmall,
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ],
          const VerticalGap(16),
          Flexible(
            child: SingleChildScrollView(
              child: child,
            ),
          ),
        ],
      ),
    );
  }
}

Future<T?> showBaseBottomSheet<T>({
  required BuildContext context,
  required Widget child,
  double? height,
  Color? backgroundColor,
  Color? barrierColor,
  BorderRadius? borderRadius,
  EdgeInsets? padding,
  bool showDragHandle = true,
  bool isDismissible = true,
  bool enableDrag = true,
  String? title,
  Widget? titleWidget,
  List<Widget>? actions,
}) {
  return showModalBottomSheet<T>(
    context: context,
    backgroundColor: Colors.transparent,
    isScrollControlled: true,
    isDismissible: isDismissible,
    enableDrag: enableDrag,
    barrierColor: barrierColor,
    builder: (context) => BaseBottomSheetDialog(
      height: height,
      backgroundColor: backgroundColor,
      borderRadius: borderRadius,
      padding: padding,
      showDragHandle: showDragHandle,
      title: title,
      child: child,
    ),
  );
}
