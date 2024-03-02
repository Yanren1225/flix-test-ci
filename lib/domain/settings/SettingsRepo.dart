import 'dart:async';

import 'package:flix/utils/buffer_broadcast.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsRepo {
  SettingsRepo._privateConstructor() {
    SharedPreferences.getInstance().then((sp) {
      _setAutoReceive(sp.getBool(autoReceiveKey) ?? false);
    });
  }

  static final SettingsRepo _instance = SettingsRepo._privateConstructor();

  static SettingsRepo get instance => _instance;

  static const autoReceiveKey = "autoReceive";

  bool _autoReceive = false;
  StreamController<bool> autoReceiveStream = StreamController.broadcast();

  Future<void> autoReceive(bool autoReceive) async {
    _setAutoReceive(autoReceive);
    var sharePreference = await SharedPreferences.getInstance();
    sharePreference.setBool(autoReceiveKey, autoReceive);
  }

  void _setAutoReceive(bool autoReceive) {
    _autoReceive = autoReceive;
    autoReceiveStream.add(autoReceive);
  }

  bool getAutoReceive() {
    return _autoReceive;
  }

  Future<bool> getAutoReceiveAsync() async {
    var sharePreference = await SharedPreferences.getInstance();
    return sharePreference.getBool(autoReceiveKey) ?? _autoReceive;
  }
}
