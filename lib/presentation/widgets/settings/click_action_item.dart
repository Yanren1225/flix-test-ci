import 'package:flix/theme/theme_extensions.dart';
import 'package:flix/presentation/basic/corner/flix_decoration.dart';
import 'package:flix/utils/text/text_extension.dart';
import 'package:flix/presentation/style/colors/flix_color.dart';
import 'package:flutter/material.dart';

class ClickActionItem extends StatelessWidget {
  final String label;
  final bool topRadius;
  final bool bottomRadius;
  final bool dangerous;

  final GestureTapCallback? onClick;

  const ClickActionItem({super.key,
    required this.label,
    this.topRadius = true,
    this.bottomRadius = true,
    this.dangerous = false,
    required this.onClick});

  @override
  Widget build(BuildContext context) {
    return InkWell(
        onTap: () {
          onClick?.call();
        },
        child: DecoratedBox(
            decoration: FlixDecoration(
                color: Theme
                    .of(context)
                    .flixColors
                    .background
                    .primary,
                borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(topRadius ? 14 : 0),
                    topRight: Radius.circular(topRadius ? 14 : 0),
                    bottomLeft: Radius.circular(bottomRadius ? 14 : 0),
                    bottomRight: Radius.circular(bottomRadius ? 14 : 0)),
            ),
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Row(
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(
                      child: Padding(
                          padding: const EdgeInsets.only(right: 12),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Text(
                                label,
                                style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.normal,
                                    color: dangerous
                                        ? FlixColor.red
                                        : Theme
                                        .of(context)
                                        .flixColors
                                        .text
                                        .primary)
                                    .fix(),
                              ),
                            ],
                          )),
                    )
                  ]),
            )));
  }
}
