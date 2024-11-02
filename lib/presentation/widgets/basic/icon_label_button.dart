import 'dart:io';

import 'package:flix/presentation/basic/corner/flix_decoration.dart';
import 'package:flix/presentation/style/colors/flix_color.dart';
import 'package:flix/theme/theme_extensions.dart';
import 'package:flix/utils/text/text_extension.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class IconLabelButton extends StatelessWidget {
  final String icon;
  final String label;
  final Color iconColor;
  final Color? labelColor;
  final bool isLeft;
  final VoidCallback? onTap;

  const IconLabelButton({
    super.key,
    required this.icon,
    required this.label,
    required this.isLeft,
    this.iconColor = FlixColor.blue,
    this.labelColor,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        height: 40,
        decoration: FlixDecoration(
            color: Theme.of(context)
                .flixColors
                .background
                .secondary
                ,
           ),
        child: Align(
          alignment: isLeft ? Alignment.centerLeft : Alignment.centerRight, 
          child: Row(mainAxisSize: MainAxisSize.min, children: [
            const SizedBox(
              width: 3,
            ),
            SvgPicture.asset(icon,
                colorFilter: ColorFilter.mode(iconColor, BlendMode.srcIn)),
            const SizedBox(
              width: 6,
            ),
            Flexible(
              child: Text(label,
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                  style: TextStyle(
                      color: labelColor ??
                              Theme.of(context).flixColors.text.primary,
                         fontSize: Platform.isAndroid || Platform.isIOS ? 15 : 13.5,
                          fontWeight: FontWeight.w400)
                      .fix()),
            ),
            const SizedBox(
              width: 3,
            ),
          ]),
        ),
      ),
    );
  }
}
