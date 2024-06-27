import 'package:flutter/material.dart';

///Foreground progress bar painter
///Requires [value] to set progress
///Optional [gradient] or [color] for bar infill
class ProgressPainter extends CustomPainter {
  const ProgressPainter({required this.value, this.gradient, this.color});

  ///current progress bar value
  final double value;

  ///progress bar gradient infill
  final Gradient? gradient;

  ///progress bar gradient color
  final Color? color;

  @override
  void paint(Canvas canvas, Size size) {
    if(size.isEmpty || size.width.isNaN || value.isNaN || size.height.isNaN) {
      return;
    }
    Paint paint = Paint();
    if (gradient != null) {
      paint.shader = gradient?.createShader(Offset.zero & Size(size.width * value, size.height));
    }
    if (color != null) {
      paint.color = color!;
    }
    // canvas.FlixClipRRect(RRect.fromRectAndRadius(
    //     Offset.zero & size, Radius.circular(size.height / 2)));
    // canvas.drawRRect(
    //     RRect.fromRectAndRadius(
    //         Rect.fromLTRB(0, 0, size.width * value, size.height),
    //         Radius.circular(size.height / 2)),
    //     paint);
    canvas.drawRect(
        Rect.fromPoints(Offset.zero, Offset(size.width * value, size.height)),
        paint);
  }

  @override
  bool shouldRepaint(covariant ProgressPainter oldDelegate) {
    return value != oldDelegate.value || color != oldDelegate.color || gradient != oldDelegate.gradient;
  }
}
