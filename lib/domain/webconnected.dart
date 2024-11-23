import 'package:flutter/material.dart';

class WebConnectionManager extends ChangeNotifier {
  static final WebConnectionManager _instance = WebConnectionManager._internal();

  factory WebConnectionManager() => _instance;

  WebConnectionManager._internal();

  bool _webConnected = false;

  bool get webConnected => _webConnected;

  void setWebConnected(bool value) {
    _webConnected = value;
    notifyListeners();
  }
}