import 'package:androp/presentation/widgets/settings/settings_label.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class SwitchableItem extends StatelessWidget {
  final String label;
  final String? des;
  final bool checked;
  final ValueChanged<bool?>? onChanged;

  const SwitchableItem(
      {super.key,
      required this.label,
      this.des,
      required this.checked,
      required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.max,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(child: SettingsLabel(label: label, des: des)),
        Switch(
          value: checked,
          onChanged: onChanged,
          inactiveTrackColor: const Color.fromRGBO(0, 0, 0, 0.1),
          inactiveThumbColor: const Color.fromRGBO(0, 0, 0, 0.25),
          activeTrackColor: const Color.fromRGBO(0, 122, 255, 1),
          activeColor: Colors.white,
          thumbColor: null,
          trackOutlineColor: MaterialStateColor.resolveWith((states) => Colors.transparent),
        )
      ],
    );
  }
}
