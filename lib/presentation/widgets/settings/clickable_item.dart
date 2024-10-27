import 'package:flutter/material.dart';
import 'package:flix/theme/theme_extensions.dart';
import 'package:flix/presentation/basic/corner/flix_decoration.dart';
import 'package:flix/utils/text/text_extension.dart';
import 'package:flix/presentation/widgets/settings/settings_label.dart';
import 'package:flutter_svg/flutter_svg.dart'; 

class ClickableItem extends StatelessWidget {
  final String label;
  final String? des;
  final String? tail;
  final Color? tailColor;
  final bool topRadius;
  final bool bottomRadius;
  final GestureTapCallback? onClick;
  final String? iconPath; 

  const ClickableItem({
    super.key,
    required this.label,
    this.des,
    this.tail,
    this.tailColor,
    this.topRadius = true,
    this.bottomRadius = true,
    this.onClick,
    this.iconPath, 
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        onClick?.call();
      },
      child: DecoratedBox(
        decoration: FlixDecoration(
          color: Theme.of(context).flixColors.background.primary,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(topRadius ? 14 : 0),
            topRight: Radius.circular(topRadius ? 14 : 0),
            bottomLeft: Radius.circular(bottomRadius ? 14 : 0),
            bottomRight: Radius.circular(bottomRadius ? 14 : 0),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              if (iconPath != null)
                Padding(
                  padding: const EdgeInsets.only(left:3,right: 12),
                  child: SvgPicture.asset(
                    iconPath!,
                    height: 20,
                    width: 20,
                    placeholderBuilder: (BuildContext context) =>
                        CircularProgressIndicator(), 
                  ),
                ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(right: 12),
                  child: SettingsLabel(label: label, des: des),
                ),
              ),
              Visibility(
                visible: tail != null,
                child: Padding(
                  padding: const EdgeInsets.only(right: 6),
                  child: Text(
                    tail ?? "",
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.normal,
                      color: tailColor ?? Theme.of(context).flixColors.text.secondary,
                    ).fix(),
                  ),
                ),
              ),
              Icon(
                Icons.arrow_forward_ios_rounded,
                size: 16,
                color: Theme.of(context).flixColors.text.secondary,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
