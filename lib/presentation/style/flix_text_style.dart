import 'package:flix/presentation/style/colors/flix_color.dart';
import 'package:flix/theme/theme_extensions.dart';
import 'package:flix/utils/text/text_extension.dart';
import 'package:flutter/material.dart';

extension FlixTextStyle on BuildContext {
  // static const TextStyle title = TextStyle(
  //   fontSize: 24,
  //   fontWeight: FontWeight.bold,
  // );

  TextStyle h1() {
    return TextStyle(
            fontSize: 36,
            fontWeight: FontWeight.w500,
            color: Theme.of(this).flixColors.text.primary)
        .fix();
  }

  TextStyle h2() {
    return TextStyle(
            fontSize: 30,
            fontWeight: FontWeight.w500,
            color: Theme.of(this).flixColors.text.primary)
        .fix();
  }

  TextStyle title() {
    return TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.normal,
            color: Theme.of(this).flixColors.text.primary)
        .fix();
  }

  TextStyle titleSecondary() {
    return TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.normal,
            color: Theme.of(this).flixColors.text.primary)
        .fix();
  }

  TextStyle body() {
    return TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.normal,
            color: Theme.of(this).flixColors.text.primary)
        .fix();
  }

  TextStyle bodyVariant() {
    return const TextStyle(
            fontSize: 14, fontWeight: FontWeight.normal, color: FlixColor.blue)
        .fix();
  }

  TextStyle onButton() {
    return const TextStyle(
            fontSize: 14, fontWeight: FontWeight.normal, color: Colors.white)
        .fix();
  }
}
