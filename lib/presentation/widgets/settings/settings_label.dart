import 'package:flix/theme/theme_extensions.dart';
import 'package:flix/utils/text/text_extension.dart';
import 'package:flutter/material.dart';

class SettingsLabel extends StatelessWidget {
  final String label;
  final String? des;

  const SettingsLabel({super.key, required this.label, required this.des});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.normal,
                  color: Theme.of(context).flixColors.text.primary)
              .fix(),
        ),
        Visibility(
            visible: des != null,
            child: Text(des ?? "",
                style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.normal,
                        color: Theme.of(context).flixColors.text.secondary)
                    .fix()))
      ],
    );
  }
}
