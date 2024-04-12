import 'dart:io';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:window_manager/window_manager.dart';

class FlixWindowManager with WindowListener {
  static const WINDOW_WIDTH_KEY = 'window_width';
  static const WINDOW_HEIGHT_KEY = 'window_height';

  FlixWindowManager._privateConstructor() {}

  @override
  void onWindowResize() async {
    super.onWindowResize();
    if (Platform.isLinux) {
      await _saveWindowSize();
    }
  }

  Future<void> _saveWindowSize() async {
    final sp = await SharedPreferences.getInstance();
    final size = await windowManager.getSize();
    await sp.setDouble(WINDOW_WIDTH_KEY, size.width);
    await sp.setDouble(WINDOW_HEIGHT_KEY, size.height);
  }

  @override
  void onWindowResized() async {
    super.onWindowResized();
    if (_isDesktop()) {
      await _saveWindowSize();
    }
  }

  static final FlixWindowManager _instance =
      FlixWindowManager._privateConstructor();

  static FlixWindowManager get instance {
    return _instance;
  }

  Future<void> init() async {
    if (_isDesktop()) {
      await windowManager.ensureInitialized();
      windowManager.setMinimumSize(const Size(400, 400));
      windowManager.addListener(this);
    }
  }

  void restoreWindow() async {
    if (_isDesktop()) {
      final sp = await SharedPreferences.getInstance();
      final size = Size(await sp.getDouble(WINDOW_WIDTH_KEY) ?? 800,
          await sp.getDouble(WINDOW_HEIGHT_KEY) ?? 600);
      WindowOptions windowOptions = WindowOptions(
        size: size,
        center: true,
      );
      windowManager.waitUntilReadyToShow(windowOptions, () async {
        await windowManager.show();
        await windowManager.focus();
      });
    }
  }

  bool _isDesktop() =>
      Platform.isMacOS || Platform.isLinux || Platform.isWindows;
}

final flixWindowsManager = FlixWindowManager.instance;
