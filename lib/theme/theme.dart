import 'package:chinese_font_library/chinese_font_library.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

ThemeData flixLight() {
  final base = ThemeData.light();

  return base
      .copyWith(
        cupertinoOverrideTheme: const CupertinoThemeData(
          brightness: Brightness.light,
        ),
        textTheme:
            const TextTheme(displayMedium: TextStyle(color: Colors.redAccent)),
        colorScheme: const ColorScheme.light(
            primary: Color.fromRGBO(0, 122, 255, 1), onPrimary: Colors.white),
      )
      .useSystemChineseFont(Brightness.light);
}

ThemeData flixDark() {
  final base = ThemeData.dark();
  return base
      .copyWith(
        cupertinoOverrideTheme: const CupertinoThemeData(
          brightness: Brightness.dark,
        ),
        colorScheme: const ColorScheme.dark(
            primary: Color.fromRGBO(0, 122, 255, 1), onPrimary: Colors.white),
      )
      .useSystemChineseFont(Brightness.dark);
}
