import 'dart:async';

import 'package:flix/utils/buffer_broadcast.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../utils/file/file_helper.dart';

class SettingsRepo {
  SettingsRepo._privateConstructor() {
    SharedPreferences.getInstance().then((sp) {
      _setAutoReceive(sp.getBool(autoReceiveKey) ?? false);
      final dir = sp.getString(savedDirKey);
      if (dir == null || dir.isEmpty) {
        getDefaultDestinationDirectory().then((desDir) {
          _setSavedDir(desDir);
        });
      } else {
        _setSavedDir(dir);
      }
    });
  }

  static final SettingsRepo _instance = SettingsRepo._privateConstructor();

  static SettingsRepo get instance => _instance;

  static const autoReceiveKey = "autoReceive";
  static const savedDirKey = "savedDir";

  bool _autoReceive = false;

  bool get autoReceive => _autoReceive;
  StreamController<bool> autoReceiveStream = StreamController.broadcast();

  String _savedDir = "";

  String get savedDir => _savedDir;
  StreamController<String> savedDirStream = StreamController.broadcast();

  Future<void> setAutoReceive(bool autoReceive) async {
    _setAutoReceive(autoReceive);
    var sharePreference = await SharedPreferences.getInstance();
    await sharePreference.setBool(autoReceiveKey, autoReceive);
  }

  void _setAutoReceive(bool autoReceive) {
    _autoReceive = autoReceive;
    autoReceiveStream.add(autoReceive);
  }

  Future<void> setSavedDir(String savedDir) async {
    _setSavedDir(savedDir);
    var sharePreference = await SharedPreferences.getInstance();
    await sharePreference.setString(savedDirKey, savedDir);
  }

  void _setSavedDir(String savedDir) {
    _savedDir = savedDir;
    savedDirStream.add(savedDir);
  }

  Future<bool> getAutoReceiveAsync() async {
    var sharePreference = await SharedPreferences.getInstance();
    return sharePreference.getBool(autoReceiveKey) ?? _autoReceive;
  }
}
