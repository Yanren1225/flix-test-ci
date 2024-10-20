import 'dart:async';

import 'package:shared_preferences/shared_preferences.dart';

import '../../utils/file/file_helper.dart';

class SettingsRepo {
  bool isInited = false;

  SettingsRepo._privateConstructor() {
    SharedPreferences.getInstance().then((sp) {
      _setAutoReceive(sp.getBool(autoReceiveKey) ?? false);
      _setAutoSaveGallery(sp.getBool(autoSaveGalleryKey)??true);
      _setEnableMdns(sp.getBool(enableMdnsKey) ?? true);
      _setMinimizedMode(sp.getBool(isMinimizedKey) ?? true);
      _setDarkModeTag(sp.getString(darkModeTagKey) ?? "follow_system");
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
  static const autoSaveGalleryKey = "autoSaveGallery";
  static const isMinimizedKey = "isMinimized";
  static const savedDirKey = "savedDir";
  static const enableMdnsKey = "enableMdns";
  static const darkModeTagKey = "darkModeTag";

  bool _isMinimized = true;
  StreamController<bool> isMinimizedStream = StreamController.broadcast();
  bool get isMinimized => _isMinimized;

  bool _autoReceive = false;
  bool get autoReceive => _autoReceive;
  StreamController<bool> autoReceiveStream = StreamController.broadcast();

  String _savedDir = "";
  String get savedDir => _savedDir;
  StreamController<String> savedDirStream = StreamController.broadcast();

  bool _autoSaveToGallery = true;
  bool get autoSaveToGallery => _autoSaveToGallery;
  StreamController<bool> autoSaveToGalleryStream = StreamController.broadcast();

  bool _enableMdns = true;
  bool get enableMdns => _enableMdns;
  StreamController<bool> enableMdnsStream = StreamController.broadcast();

  String _darkModeTag = "";
  String get darkModeTag => _darkModeTag;
  StreamController<String> darkModeTagStream = StreamController.broadcast();

  Future<void> setAutoSaveToGallery(bool autoSaveToGallery) async {
    _autoSaveToGallery = autoSaveToGallery;
    autoSaveToGalleryStream.add(autoSaveToGallery);
    var sharePreference = await SharedPreferences.getInstance();
    await sharePreference.setBool(autoSaveGalleryKey, autoSaveToGallery);
  }

  void _setAutoSaveGallery(bool autoSaveToGallery){
    _autoSaveToGallery = autoSaveToGallery;
    autoSaveToGalleryStream.add(autoSaveToGallery);
  }

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

  Future setDarkModeTag(String darkModeTag) async {
    _setDarkModeTag(darkModeTag);
    var sharePreference = await SharedPreferences.getInstance();
    await sharePreference.setString(darkModeTagKey, _darkModeTag);
  }

  void _setDarkModeTag(String darkModeTag) {
    _darkModeTag = darkModeTag;
    darkModeTagStream.add(_darkModeTag);
  }

  Future<String> getDarkModeTag() async {
    var sharePreference = await SharedPreferences.getInstance();
    return sharePreference.getString(darkModeTagKey) ?? _darkModeTag;
  }
}
