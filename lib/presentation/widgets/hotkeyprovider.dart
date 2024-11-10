import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hotkey_manager/hotkey_manager.dart';

class HotKeyProvider with ChangeNotifier {
  HotKey _hotKey = HotKey(
    key: PhysicalKeyboardKey.keyF,
    modifiers: [HotKeyModifier.alt],
    scope: HotKeyScope.system,
  );

  HotKey get hotKey => _hotKey;

  void updateHotKey(HotKey newHotKey) {
    _hotKey = newHotKey;
    notifyListeners();
  }
}
