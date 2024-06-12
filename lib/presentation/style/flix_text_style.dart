import 'package:flix/presentation/style/colors/flix_color.dart';
import 'package:flix/utils/text/text_extension.dart';
import 'package:flutter/material.dart';

class FlixTextStyle {
  // static const TextStyle title = TextStyle(
  //   fontSize: 24,
  //   fontWeight: FontWeight.bold,
  // );

  static TextStyle head = const TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.normal,
    color: FlixColor.labels_primary
  ).fix();

  static TextStyle head_secondary = const TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.normal,
    color: FlixColor.labels_primary
  ).fix();

  static TextStyle body = const TextStyle(
      fontSize: 14,
      fontWeight: FontWeight.normal,
      color: Colors.black
  ).fix();

  static TextStyle body_variant = const TextStyle(
      fontSize: 14,
      fontWeight: FontWeight.normal,
      color: FlixColor.blue
  ).fix();
  // static const TextStyle subtitle = TextStyle(
  //   fontSize: 18,
  //   fontWeight: FontWeight.bold,
  // );
  //
  // static const TextStyle body = TextStyle(
  //   fontSize: 16,
  // );
  //
  // static const TextStyle caption = TextStyle(
  //   fontSize: 14,
  // );
}