import 'package:flutter/material.dart';

import '../constants/ui_constants.dart';

class DefaultPageWrapper extends StatelessWidget {
  final EdgeInsets padding;
  final List<Widget> children;
  final CrossAxisAlignment? crossAxisAlignment;

  const DefaultPageWrapper(
      {Key? key,
        required this.children,
        this.crossAxisAlignment = CrossAxisAlignment.start,
        this.padding = const EdgeInsets.symmetric(
            horizontal: UIConstants.defaultHorizontalPadding)})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding:padding,
      child: CustomScrollConfiguration(
          child: CustomScrollView(
            slivers: [
              SliverFillRemaining(
                hasScrollBody: false,
                child: Column(
                  crossAxisAlignment: crossAxisAlignment!,
                  children: children,
                ),
              )
            ],
          )),
    );
  }
}
class CustomScrollConfiguration extends StatelessWidget {
  final Widget child;

  /// Removes Glow Effect on scrolling
  const CustomScrollConfiguration({Key? key, required this.child})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return NotificationListener<OverscrollIndicatorNotification>(
        onNotification: (OverscrollIndicatorNotification overscroll) {
          overscroll.disallowIndicator();
          return false;
        },
        child: child);
  }
}
