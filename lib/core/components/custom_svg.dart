import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:vector_graphics/vector_graphics.dart';

class CustomSvg extends StatelessWidget {
  final String asset;
  final Color color;
  final double width;
  final double height;
  final bool isNetwork;

  const CustomSvg(
      {super.key,
      required this.asset,
      required this.color,
      this.isNetwork = false,
      this.width = 24,
      this.height = 24});

  @override
  Widget build(BuildContext context) {
    return isNetwork
        ? SvgPicture.network(
            asset,
            colorFilter: ColorFilter.mode(color, BlendMode.srcIn),
            width: width,
            height: height,
          )
        : VectorGraphic(
            loader: AssetBytesLoader(asset),
            colorFilter: ColorFilter.mode(color, BlendMode.srcIn),
            width: width,
            height: height,
          );
  }
}
