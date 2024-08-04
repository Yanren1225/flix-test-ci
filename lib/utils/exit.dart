import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';

bool showExit() {
  if (!kReleaseMode){
    return true;
  }
  return Platform.isWindows;
}

void doExit() {
  //TODO: Implement exit for other platforms
  if (Platform.isAndroid) {
    SystemNavigator.pop();
    return;
  }
  exit(0);
}
