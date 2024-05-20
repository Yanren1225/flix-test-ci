import 'package:flix/utils/text/text_extension.dart';
import 'package:flix/presentation/widgets/settings/settings_label.dart';
import 'package:flutter/material.dart';

class ClickableItem extends StatelessWidget {
  final String label;
  final String? des;
  final String? tail;
  final bool topRadius;
  final bool bottomRadius;

  final GestureTapCallback? onClick;

  const ClickableItem(
      {super.key,
      required this.label,
      this.des,
      this.tail,
      this.topRadius = true,
      this.bottomRadius = true,
      required this.onClick});

  @override
  Widget build(BuildContext context) {
    return InkWell(
        onTap: () {
          onClick?.call();
        },
        child: DecoratedBox(
            decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(topRadius ? 14 : 0),
                    topRight: Radius.circular(topRadius ? 14 : 0),
                    bottomLeft: Radius.circular(bottomRadius ? 14 : 0),
                    bottomRight: Radius.circular(bottomRadius ? 14 : 0))),
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
                            child: SettingsLabel(label: label, des: des))),
                    Visibility(
                        visible: tail != null,
                        child: Padding(
                          padding: const EdgeInsets.only(right: 6),
                          child: Text(tail ?? "",
                              style: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.normal,
                                      color: Color.fromRGBO(60, 60, 67, 0.6))
                                  .fix()),
                        )),
                    const Icon(Icons.arrow_forward_ios_rounded,
                        size: 16, color: Color.fromRGBO(60, 60, 67, 0.6))
                  ],
                ))));
  }
}
