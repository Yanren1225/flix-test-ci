import 'package:flutter/widgets.dart';

abstract class RouterHandler {
  abstract final String host;

  Future<bool> handle(BuildContext context, Uri uri);
}