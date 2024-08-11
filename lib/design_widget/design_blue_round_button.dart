import 'dart:io';

import 'package:flix/theme/theme_extensions.dart';
import 'package:flix/utils/text/text_extension.dart';
import 'package:flutter/material.dart';

class DesignBlueRoundButton extends StatefulWidget {
  final VoidCallback? onPressed;
  final String text;

  const DesignBlueRoundButton({
    super.key,
    this.onPressed,
    required this.text,
  });

  @override
  State<StatefulWidget> createState() {
    return DesignBlueRoundButtonState();
  }

  static InputDecoration getInputDecoration(BuildContext context) {
    return InputDecoration(
        isDense: true,
        // hintText: 'Input something.',
        border: OutlineInputBorder(
          borderSide: BorderSide.none,
          gapPadding: 0,
          borderRadius: BorderRadius.circular(10.0),
        ),
        filled: true,
        fillColor: Theme.of(context).flixColors.background.primary,
        hoverColor: Theme.of(context).flixColors.background.primary,
        contentPadding: EdgeInsets.only(
            left: 12,
            right: 12,
            top: 8,
            bottom: Platform.isMacOS || Platform.isWindows || Platform.isLinux
                ? 16
                : 8));
  }

  static TextStyle getTextStyle(BuildContext context) {
    return TextStyle(
            color: Theme.of(context).flixColors.text.primary,
            fontSize: 16,
            fontWeight: FontWeight.normal)
        .fix();
  }
}

class DesignBlueRoundButtonState extends State<DesignBlueRoundButton> {
  @override
  Widget build(BuildContext context) {
    return MaterialButton(
        onPressed: widget.onPressed,
        elevation: 0,
        color: const Color.fromRGBO(0, 122, 255, 1),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15.0), // 设置圆角
        ),
        child: SizedBox(
            height: 56,
            child: Center(
                child: Text(
              widget.text,
              style: const TextStyle(fontSize: 18, color: Colors.white),
            ))));
  }
}
