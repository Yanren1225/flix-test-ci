import 'package:flutter/material.dart';
import 'package:window_manager/window_manager.dart';

class WindowState with ChangeNotifier {
  bool _isPinned = false;

  bool get isPinned => _isPinned;

  WindowState() {
    _initializeAlwaysOnTopStatus();
  }

  Future<void> _initializeAlwaysOnTopStatus() async {
    _isPinned = await windowManager.isAlwaysOnTop();
    notifyListeners();
  }

  Future<void> toggleAlwaysOnTop() async {
    _isPinned = !_isPinned;
    await windowManager.setAlwaysOnTop(_isPinned);
    notifyListeners();
  }
}
