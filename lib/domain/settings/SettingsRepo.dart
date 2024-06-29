import 'dart:async';

import 'package:shared_preferences/shared_preferences.dart';

import '../../utils/file/file_helper.dart';

class SettingsRepo {
  bool isInited = false;

  SettingsRepo._privateConstructor() {
    SharedPreferences.getInstance().then((sp) {
      _setAutoReceive(sp.getBool(autoReceiveKey) ?? false);
      _setEnableMdns(sp.getBool(enableMdnsKey) ?? true);
      _setMinimizedMode(sp.getBool(isMinimizedKey) ?? true);
      _setDarkFollowSystem(sp.getBool(darkFollowSystemKey) ?? false);
      _setDarkMode(sp.getBool(darkModeKey) ?? false);
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
  static const isMinimizedKey = "isMinimized";
  static const savedDirKey = "savedDir";
  static const enableMdnsKey = "enableMdns";
  static const darkFollowSystemKey = "darkFollowSystem";
  static const darkModeKey = "darkMode";

  bool _isMinimized = true;
  StreamController<bool> isMinimizedStream = StreamController.broadcast();
  bool get isMinimized => _isMinimized;

  bool _autoReceive = false;
  bool get autoReceive => _autoReceive;
  StreamController<bool> autoReceiveStream = StreamController.broadcast();

  String _savedDir = "";
  String get savedDir => _savedDir;
  StreamController<String> savedDirStream = StreamController.broadcast();

  bool _enableMdns = true;
  bool get enableMdns => _enableMdns;
  StreamController<bool> enableMdnsStream = StreamController.broadcast();

  bool _darkFollowSystem = false;
  bool get darkFollowSystem => _darkFollowSystem;
  StreamController<bool> darkFollowSystemStream = StreamController.broadcast();

  bool _darkMode = false;
  bool get darkMode => _darkMode;
  StreamController<bool> darkModeStream = StreamController.broadcast();

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

  Future<void> setMinimizedMode(bool miniMode) async {
    _setMinimizedMode(miniMode);
    var sharePreference = await SharedPreferences.getInstance();
    await sharePreference.setBool(isMinimizedKey, _isMinimized);
  }

  void _setMinimizedMode(bool miniMode) {
    _isMinimized = miniMode;
    isMinimizedStream.add(_isMinimized);
  }

  Future<bool> isMinimizedMode() async {
    var sharePreference = await SharedPreferences.getInstance();
    return sharePreference.getBool(isMinimizedKey) ?? _isMinimized;
  }

  Future<void> setDarkFollowSystem(bool darkFollowSystem) async {
    _setDarkFollowSystem(darkFollowSystem);
    var sharePreference = await SharedPreferences.getInstance();
    await sharePreference.setBool(darkFollowSystemKey, _darkFollowSystem);
  }

  void _setDarkFollowSystem(bool darkFollowSystem) {
    _darkFollowSystem = darkFollowSystem;
    darkFollowSystemStream.add(_darkFollowSystem);
  }

  Future<bool> isDarkFollowSystem() async {
    var sharePreference = await SharedPreferences.getInstance();
    return sharePreference.getBool(darkFollowSystemKey) ?? _darkFollowSystem;
  }

  Future<void> setDarkMode(bool darkMode) async {
    _setDarkMode(darkMode);
    var sharePreference = await SharedPreferences.getInstance();
    await sharePreference.setBool(darkModeKey, _darkMode);
  }

  void _setDarkMode(bool darkMode) {
    _darkMode = darkMode;
    darkModeStream.add(_darkMode);
  }

  Future<bool> isDarkMode() async {
    var sharePreference = await SharedPreferences.getInstance();
    return sharePreference.getBool(darkModeKey) ?? _darkMode;
  }
}
