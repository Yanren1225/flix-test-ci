import 'package:flix/presentation/basic/corner/flix_decoration.dart';
import 'package:flix/presentation/style/colors/flix_color.dart';
import 'package:flix/utils/text/text_extension.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class IconLabelButton extends StatelessWidget {
  final String icon;
  final String label;
  final Color iconColor;
  final Color labelColor;
  final bool isLeft;
  final VoidCallback? onTap;

  const IconLabelButton({
    super.key,
    required this.icon,
    required this.label,
    required this.isLeft,
    this.iconColor = FlixColor.blue,
    this.labelColor = FlixColor.labels_primary,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        height: 43,
        decoration: FlixDecoration(
            color: FlixColor.white_half_transparent,
            borderRadius: isLeft
                ? const BorderRadius.only(
                    topLeft: Radius.circular(21.5),
                    bottomLeft: Radius.circular(21.5),
                    topRight: Radius.circular(2),
                    bottomRight: Radius.circular(2))
                : const BorderRadius.only(
                    topLeft: Radius.circular(2),
                    bottomLeft: Radius.circular(2),
                    topRight: Radius.circular(21.5),
                    bottomRight: Radius.circular(21.5))),
        child: Center(
          child: Row(mainAxisSize: MainAxisSize.min, children: [
            const SizedBox(
              width: 6,
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
                          color: labelColor,
                          fontSize: 16,
                          fontWeight: FontWeight.w400)
                      .fix()),
            ),
            const SizedBox(
              width: 6,
            ),
          ]),
        ),
      ),
    );
  }
}
