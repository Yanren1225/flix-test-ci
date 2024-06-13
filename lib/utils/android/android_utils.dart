import 'dart:io';

import 'package:android_intent/android_intent.dart';

class AndroidUtils {
  static openSettings() async {
    if (Platform.isAndroid) {
      AndroidIntent intent = const AndroidIntent(
        action: 'android.settings.SETTINGS',
      );
      await intent.launch();
    }
  }

  static openWifiSettings() async {
    if (Platform.isAndroid) {
      AndroidIntent intent = const AndroidIntent(
        action: 'android.settings.WIFI_SETTINGS',
      );
      await intent.launch();
    }
  }
}