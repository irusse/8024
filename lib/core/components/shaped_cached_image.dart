import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:neighbours/core/extensions/context_ext.dart';

class ShapedCachedImage extends StatelessWidget {
  final String? url;
  final double? radius;
  final double? width;
  final double? height;
  final Border? border;
  final bool isSquare;

  const ShapedCachedImage({
    Key? key,
    this.url,
    this.radius,
    this.width,
    this.height,
    this.border,
    this.isSquare = false,
  })  : assert(
          radius != null || (width != null && height != null),
          'ShapedCachedImage requires either radius or both width and height.',
        ),
        super(key: key);

  @override
  Widget build(BuildContext context) {
    final double w = width ?? radius! * 2;
    final double h = height ?? radius! * 2;

    final shape = isSquare ? BoxShape.rectangle : BoxShape.circle;
    final borderRadius = isSquare ? BorderRadius.circular(8) : null;

    return url == null
        ? Container(
            width: w,
            height: h,
            decoration: BoxDecoration(
              color: context.color.tertiary,
              shape: shape,
              borderRadius: borderRadius,
              border: border,
            ),
            child: const Icon(
              Icons.camera_alt_outlined,
              color: Colors.white,
            ),
          )
        : CachedNetworkImage(
            imageUrl: url!,
            imageBuilder: (context, imageProvider) => Container(
              width: w,
              height: h,
              decoration: BoxDecoration(
                shape: shape,
                borderRadius: borderRadius,
                image: DecorationImage(
                  image: imageProvider,
                  fit: BoxFit.cover,
                ),
                border: border,
              ),
            ),
            progressIndicatorBuilder: (context, url, progress) => SizedBox(
              width: w,
              height: h,
              child: Center(
                child: CircularProgressIndicator(
                  value: progress.progress,
                  color: context.color.primary,
                  strokeWidth: 1,
                ),
              ),
            ),
            errorWidget: (context, url, error) => Icon(
              Icons.error,
              size: radius,
              color: context.color.basicRed,
            ),
          );
  }
}
