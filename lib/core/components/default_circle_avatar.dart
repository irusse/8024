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
  final bool withShadow;

  const DefaultCircleAvatar({
    super.key,
    required this.name,
    required this.radius,
    required this.textStyle,
    this.url,
    this.id,
    this.withShadow = false,
  });

  @override
  Widget build(BuildContext context) {
    final avatar = url == null || url!.isEmpty
        ? _buildInitials(context)
        : ShapedCachedImage(
            url: url,
            radius: radius,
            errorWidget: _buildInitials(context),
          );

    if (!withShadow) return avatar;

    return Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: .15),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: avatar,
    );
  }

  Widget _buildInitials(BuildContext context) {
    return CircleAvatar(
      radius: radius,
      backgroundColor: id != null
          ? ColorExtension.byIndex(id!).withValues(alpha: 0.65)
          : context.color.primary.withValues(alpha: 0.65),
      child: Text(
        name.isNotEmpty ? name[0].toUpperCase() : '?',
        style: textStyle.copyWith(
          fontWeight: FontWeight.w700,
          color: Colors.white,
        ),
      ),
    );
  }
}
