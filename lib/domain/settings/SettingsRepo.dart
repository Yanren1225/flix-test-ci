import 'dart:async';

import 'package:shared_preferences/shared_preferences.dart';

import '../../utils/file/file_helper.dart';

class SettingsRepo {
  bool isInited = false;

  SettingsRepo._privateConstructor() {
    SharedPreferences.getInstance().then((sp) {
      _setAutoReceive(sp.getBool(autoReceiveKey) ?? false);
      _setEnableMdns(sp.getBool(enableMdnsKey) ?? true);
      final dir = sp.getString(savedDirKey);
      if (dir == null || dir.isEmpty) {
        getDefaultDestinationDirectory().then((desDir) {
          _setSavedDir(desDir);
        });
      } else {
        _setSavedDir(dir);
      }
      isInited = true;
    });
  }

  static final SettingsRepo _instance = SettingsRepo._privateConstructor();

  static SettingsRepo get instance => _instance;

  static const autoReceiveKey = "autoReceive";
  static const savedDirKey = "savedDir";
  static const enableMdnsKey = "enableMdns";

  bool _autoReceive = false;

  bool get autoReceive => _autoReceive;
  StreamController<bool> autoReceiveStream = StreamController.broadcast();

  String _savedDir = "";

  String get savedDir => _savedDir;
  StreamController<String> savedDirStream = StreamController.broadcast();

  bool _enableMdns = true;

  bool get enableMdns => _enableMdns;
  StreamController<bool> enableMdnsStream = StreamController.broadcast();

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

  Future<void> setEnableMdns(bool enableMdns) async {
    _setEnableMdns(enableMdns);
    var sharePreference = await SharedPreferences.getInstance();
    await sharePreference.setBool(enableMdnsKey, enableMdns);
  }

  void _setEnableMdns(bool enableMdns) {
    _enableMdns = enableMdns;
    enableMdnsStream.add(enableMdns);
  }

  Future<bool> getAutoReceiveAsync() async {
    var sharePreference = await SharedPreferences.getInstance();
    return sharePreference.getBool(autoReceiveKey) ?? _autoReceive;
  }

  Future<bool> getEnableMdnsAsync() async {
    if (isInited) {
      return _enableMdns;
    }
    var sharePreference = await SharedPreferences.getInstance();
    return sharePreference.getBool(enableMdnsKey) ?? _enableMdns;
  }
}
