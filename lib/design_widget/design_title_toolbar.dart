import 'package:flix/theme/theme_extensions.dart';
import 'package:flutter/material.dart';

class DesignTitleToolbar extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return DesignTitleToolbarState();
  }
}

class DesignTitleToolbarState extends State<DesignTitleToolbar> {
  @override
  Widget build(BuildContext context) {
    return AppBar(
      leading: GestureDetector(
        onTap: () {
          if (Navigator.canPop(context)) {
            Navigator.pop(context);
          }
        },
        child: Icon(
          Icons.arrow_back_ios,
          color: Theme.of(context).flixColors.text.primary,
          size: Navigator.canPop(context) ? 20 : 0,
        ),
      ),
      backgroundColor: Theme.of(context).flixColors.background.secondary,
    );
  }
}
