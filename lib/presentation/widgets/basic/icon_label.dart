import 'package:flix/presentation/style/colors/flix_color.dart';
import 'package:flix/utils/text/text_extension.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class IconLabel extends StatelessWidget {
  final String icon;
  final String label;
  final Color iconColor;
  final Color labelColor;

  const IconLabel(
      {super.key,
      required this.icon,
      required this.label,
      this.iconColor = FlixColor.blue,
      this.labelColor = FlixColor.labels_primary});

  @override
  Widget build(BuildContext context) {
    return Row(mainAxisSize: MainAxisSize.min, children: [
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
                    color: labelColor, fontSize: 16, fontWeight: FontWeight.w400)
                .fix()),
      )
    ]);
  }
}
