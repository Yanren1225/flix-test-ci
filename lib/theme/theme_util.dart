import 'package:flutter/material.dart';

bool isDarkMode(BuildContext context) {
  final isDarkMode = Theme.of(context).brightness == Brightness.dark;
  return isDarkMode;
}
