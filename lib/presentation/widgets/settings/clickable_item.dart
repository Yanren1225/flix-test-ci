import 'package:anydrop/presentation/widgets/settings/settings_label.dart';
import 'package:flutter/material.dart';

class ClickableItem extends StatelessWidget {
  final String label;
  final String? des;
  final String? tail;
  final GestureTapCallback? onClick;

  const ClickableItem(
      {super.key,
      required this.label,
      this.des,
      this.tail,
      required this.onClick});

  @override
  Widget build(BuildContext context) {
    return Row(
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
                      color: Color.fromRGBO(60, 60, 67, 0.6))),
            )),
        const Icon(Icons.arrow_forward_ios_rounded,
            size: 16, color: Color.fromRGBO(60, 60, 67, 0.6))
      ],
    );
  }
}
