import 'dart:ui';

import 'package:flutter/material.dart';

class BlurAppBar extends StatelessWidget implements PreferredSizeWidget {
  final AppBar appBar;

  const BlurAppBar({super.key, required this.appBar});

  @override
  Widget build(BuildContext context) {
    return ClipRect(
      child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 30, sigmaY: 30), child: appBar),
    );
  }

  @override
  Size get preferredSize => appBar.preferredSize;
}
