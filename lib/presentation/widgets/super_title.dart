
import 'package:flix/utils/text/text_extension.dart';
import 'package:flutter/material.dart';

class SuperTitle extends StatelessWidget {
  final String title;

  const SuperTitle({
    super.key,
    required this.title
  });

  @override
  Widget build(BuildContext context) {
    return Text(title,
        style: TextStyle(
            color: Colors.black,
            fontSize: 36.0,
            fontWeight: FontWeight.w300).fix());
  }
}