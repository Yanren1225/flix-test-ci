import 'package:figma_squircle/figma_squircle.dart';
import 'package:flix/presentation/basic/corner/flix_decoration.dart';
import 'package:flutter/cupertino.dart';

class FlixClipRRect extends ClipSmoothRect  {

  FlixClipRRect({
    Key? key,
    BorderRadiusGeometry borderRadius = BorderRadius.zero,
    Clip clipBehavior = Clip.antiAlias,
    required Widget child,
  }): super(key: key, clipBehavior: clipBehavior, radius: SmoothBorderRadius.only(
    topLeft: buildSmoothRadius((borderRadius as BorderRadius).topLeft.x),
    topRight: buildSmoothRadius((borderRadius as BorderRadius).topRight.x),
    bottomLeft: buildSmoothRadius((borderRadius as BorderRadius).bottomLeft.x),
    bottomRight: buildSmoothRadius((borderRadius as BorderRadius).bottomRight.x),
  ), child: child);



}