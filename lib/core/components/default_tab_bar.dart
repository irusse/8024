import 'package:flutter/material.dart';
import 'package:neighbours/core/extensions/context_ext.dart';

class DefaultTabBar extends StatelessWidget {
  final List<String> tabs;

  const DefaultTabBar({super.key, required this.tabs});

  @override
  Widget build(BuildContext context) {
    return TabBar(
      splashBorderRadius: BorderRadius.zero,
      tabAlignment: TabAlignment.start,
      isScrollable: true,
      tabs: tabs.map((t) => _customTab(context, t)).toList(),
      labelStyle: context.text.bodyMedium,
      indicator: BoxDecoration(
        color: context.color.primary,
        borderRadius: BorderRadius.circular(8.0),
      ),
      indicatorPadding: EdgeInsets.zero,
      dividerHeight: 0,
      labelColor: Colors.white,
      unselectedLabelColor: context.color.secondaryText,
    );
  }
}

Widget _customTab(BuildContext context, String text) {
  return Tab(
    height: 32,
    child: Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Text(text),
    ),
  );
}
