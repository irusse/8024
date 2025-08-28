import 'package:flutter/material.dart';

class VerticalGap extends StatelessWidget {
  final double? space;

  const VerticalGap(this.space, {super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(height: space);
  }
}

class HorizontalGap extends StatelessWidget {
  final double? space;

  const HorizontalGap(this.space, {super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(width: space);
  }
}
