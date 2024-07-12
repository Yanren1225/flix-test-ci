import 'dart:ui';

import 'package:flutter/material.dart';

class BlurAppBar extends StatelessWidget implements PreferredSizeWidget {
  final Widget appBar;
  final Size cpreferredSize;

  const BlurAppBar({super.key, required this.appBar, required this.cpreferredSize});

  @override
  Widget build(BuildContext context) {
    return ClipRect(
      child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 30, sigmaY: 30), child: appBar),
    );
  }

  @override
  Size get preferredSize => cpreferredSize;
}
