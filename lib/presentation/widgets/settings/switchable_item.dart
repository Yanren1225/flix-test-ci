import 'package:flix/presentation/widgets/settings/settings_label.dart';
import 'package:flix/theme/theme_extensions.dart';
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
          inactiveTrackColor:
              Theme.of(context).flixColors.switchable.inactive.track,
          inactiveThumbColor:
              Theme.of(context).flixColors.switchable.inactive.thumb,
          activeTrackColor:
              Theme.of(context).flixColors.switchable.active.track,
          activeColor: Theme.of(context).flixColors.switchable.active.thumb,
          thumbColor: null,
          trackOutlineColor:
              MaterialStateColor.resolveWith((states) => Colors.transparent),
        )
      ],
    );
  }
}
