import 'package:figma_squircle/figma_squircle.dart';
import 'package:flutter/widgets.dart';

class FlixDecoration extends Decoration {
  final ShapeDecoration _decoration;

  FlixDecoration({
    Color? color,
    DecorationImage? image,
    BorderRadiusGeometry? borderRadius,
    List<BoxShadow>? boxShadow,
    Gradient? gradient,
  }) : _decoration = ShapeDecoration(
            color: color,
            image: image,
            gradient: gradient,
            shadows: boxShadow,
            shape: SmoothRectangleBorder(
                borderRadius: borderRadius != null
                    ? SmoothBorderRadius.only(
                        topLeft: buildSmoothRadius(
                            (borderRadius as BorderRadius).topLeft.x),
                        topRight: buildSmoothRadius(
                            (borderRadius as BorderRadius).topRight.x),
                        bottomLeft: buildSmoothRadius(
                            (borderRadius as BorderRadius).bottomLeft.x),
                        bottomRight: buildSmoothRadius(
                            (borderRadius as BorderRadius).bottomRight.x),
                      )
                    : SmoothBorderRadius.zero));

  @override
  BoxPainter createBoxPainter([VoidCallback? onChanged]) {
    return _decoration.createBoxPainter(onChanged);
  }
}

SmoothRadius buildSmoothRadius(double radius) {
  return SmoothRadius(cornerRadius: radius, cornerSmoothing: 0.6);
}
