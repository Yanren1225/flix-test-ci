import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';

bool showExit() {

  final showExit = [
    Platform.isLinux,
    Platform.isMacOS,
    Platform.isWindows,
    Platform.isAndroid,
  ];

  if (!kReleaseMode){
    return true;
  }

  return showExit.contains(true);
}

void doExit() {
  //TODO: Implement exit for other platforms
  if (Platform.isAndroid) {
    SystemNavigator.pop();
  }
  exit(0);
}
