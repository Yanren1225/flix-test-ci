import 'dart:io';

bool isDesktop() {
  return Platform.isMacOS || Platform.isWindows || Platform.isLinux;
}

bool isMobile() {
  return Platform.isAndroid || Platform.isIOS|| Platform.isFuchsia;
}