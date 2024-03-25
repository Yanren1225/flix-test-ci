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
          style: const TextStyle(
              fontSize: 16, fontWeight: FontWeight.normal, color: Colors.black),
        ),
        Visibility(
          visible: des != null,
            child: Text(des ?? "",
                style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.normal,
                    color: Color.fromRGBO(60, 60, 67, 0.6))))
      ],
    );
  }
}
