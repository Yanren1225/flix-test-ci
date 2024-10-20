import 'package:flix/domain/settings/settings_repo.dart';
import 'package:flutter/cupertino.dart';

extension ResourceExtension on BuildContext {
  String imagePath(String name) {
    if (isDarkMode()) {
      return "assets/images/dark/$name";
    } else {
      return "assets/images/light/$name";
    }
  }

  bool isDarkMode() {
    final darkModeTag = SettingsRepo.instance.darkModeTag;
    return darkModeTag == "follow_system"
        ? MediaQuery.of(this).platformBrightness == Brightness.dark
        : darkModeTag == "always_on";
  }
}
