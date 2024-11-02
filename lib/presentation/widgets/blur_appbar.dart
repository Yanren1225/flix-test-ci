import 'dart:ui';

import 'package:flix/theme/theme_extensions.dart';
import 'package:flutter/material.dart';

class BlurAppBar extends StatelessWidget implements PreferredSizeWidget {
  final Widget appBar;
  final Size cpreferredSize;

  const BlurAppBar({super.key, required this.appBar, required this.cpreferredSize});

  @override
  Widget build(BuildContext context) {
    return ClipRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          color: Theme.of(context).flixColors.background.secondary.withOpacity(0.7), 
          child: appBar,
        ),
      ),
    );
  }

  @override
  Size get preferredSize => cpreferredSize;
}
