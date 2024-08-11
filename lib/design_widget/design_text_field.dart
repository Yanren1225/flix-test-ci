import 'dart:io';

import 'package:flix/theme/theme_extensions.dart';
import 'package:flix/utils/text/text_extension.dart';
import 'package:flutter/material.dart';

class DesignTextField extends StatefulWidget {
  final TextEditingController? controller;
  final ValueChanged<String>? onChanged;
  final TextInputType? keyboardType;

  const DesignTextField(
      {super.key,
      this.controller,
      this.onChanged,
      this.keyboardType = TextInputType.multiline});

  @override
  State<StatefulWidget> createState() {
    return DesignTextFieldState();
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

class DesignTextFieldState extends State<DesignTextField> {
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return TextField(
        style: DesignTextField.getTextStyle(context),
        keyboardType: widget.keyboardType,
        controller: widget.controller,
        onChanged: widget.onChanged,
        decoration: DesignTextField.getInputDecoration(context));
  }
}
