import 'dart:io';

class PlatformUtil {
  static bool isMobile() {
    return Platform.isAndroid || Platform.isIOS;
  }
}
