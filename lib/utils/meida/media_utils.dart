import 'package:flutter/cupertino.dart';

bool isOverMediumWidth(BuildContext context) {
  return MediaQuery.of(context).size.width > 600;
}