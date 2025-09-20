import 'package:flutter/material.dart';
import 'package:neighbours/core/components/shaped_cached_image.dart';
import 'package:neighbours/core/extensions/color_ext.dart';
import 'package:neighbours/core/extensions/context_ext.dart';

class DefaultCircleAvatar extends StatelessWidget {
  final String? url;
  final String name;
  final double radius;
  final TextStyle textStyle;
  final int? id;

  const DefaultCircleAvatar(
      {super.key,
      required this.name,
      required this.radius,
      required this.textStyle,
      this.url,
      this.id});

  @override
  Widget build(BuildContext context) {
    if (url == null || url!.isEmpty) {
      return CircleAvatar(
        radius: radius,
        backgroundColor:
            id != null ? ColorExtension.byIndex(id!) : context.color.tertiary,
        child: Text(
          name.isNotEmpty ? name[0].toUpperCase() : '?',
          style: textStyle.copyWith(
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
      );
    }
    return ShapedCachedImage(
      url: url,
      radius: radius,
    );
  }
}
