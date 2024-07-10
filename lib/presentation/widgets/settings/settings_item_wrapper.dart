import 'package:flix/theme/theme_extensions.dart';
import 'package:flix/presentation/basic/corner/flix_decoration.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class SettingsItemWrapper extends StatelessWidget {
  final bool topRadius;
  final bool bottomRadius;
  final Widget child;

  const SettingsItemWrapper(
      {super.key,
      this.topRadius = true,
      this.bottomRadius = true,
      required this.child});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        DecoratedBox(
          decoration: FlixDecoration(
              color: Theme.of(context).flixColors.background.primary,
              borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(topRadius ? 14 : 0),
                  topRight: Radius.circular(topRadius ? 14 : 0),
                  bottomLeft: Radius.circular(bottomRadius ? 14 : 0),
                  bottomRight: Radius.circular(bottomRadius ? 14 : 0))),
          child: Padding(padding: const EdgeInsets.all(14), child: child),
        ),
        Visibility(
          visible: !bottomRadius,
          child: Container(
            margin: const EdgeInsets.only(left: 14),
            height: 0.5,
            color: const Color.fromRGBO(0, 0, 0, 0.08),
          ),
        )
      ],
    );
  }
}
