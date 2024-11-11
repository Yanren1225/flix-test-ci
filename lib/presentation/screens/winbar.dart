import 'dart:io';
import 'dart:ui' as ui;

import 'package:flix/design_widget/design_blue_round_button.dart';
import 'package:flix/theme/theme_extensions.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:window_manager/window_manager.dart';
import 'package:flix/presentation/screens/paircode/add_device_screen.dart';
import 'package:flix/presentation/screens/paircode/pair_code_screen.dart';
import 'package:flix/presentation/screens/devices_screen.dart';

class WinBarScreen extends StatefulWidget {
  const WinBarScreen({Key? key}) : super(key: key);

  @override
  _WinBarScreenState createState() => _WinBarScreenState();
}

class _WinBarScreenState extends State<WinBarScreen> with WindowListener {
  late Size originalSize;

  @override
  void initState() {
    super.initState();
    _setInitialWindowPosition(); 
    windowManager.addListener(this);
  }

  @override
  void dispose() {
    _restoreWindowSize();
    windowManager.removeListener(this);
    super.dispose();
  }

  Future<void> _setInitialWindowPosition() async {
   
    final screenSize = ui.window.physicalSize / ui.window.devicePixelRatio;
    final screenWidth = screenSize.width;
    final screenHeight = screenSize.height;
    
    
    final windowWidth = 20; 
    final windowHeight = 260; 

    
    await windowManager.setPosition(Offset(screenWidth - windowWidth, screenHeight - windowHeight));
    await _minimizeWindowSize();
  }

  Future<void> _minimizeWindowSize() async {
    originalSize = await windowManager.getSize();
    await windowManager.setSize(const Size(400, 300));
  }

  Future<void> _restoreWindowSize() async {
    await windowManager.setSize(originalSize);
  }

  Future<void> _centerWindow() async {
    await windowManager.center(); 
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        await _restoreWindowSize();
        await Future.delayed(const Duration(milliseconds: 100));
        return true;
      },
      child: Scaffold(
        body: Stack(
          children: [
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: GestureDetector(
                onPanStart: (details) {
                  windowManager.startDragging();
                },
                onDoubleTap: () async {
                  bool isMaximized = await windowManager.isMaximized();
                  if (isMaximized) {
                    windowManager.restore();
                  } else {
                    windowManager.maximize();
                  }
                },
                child: Container(
                  height: 30.0,
                  color: Colors.transparent,
                  padding: const EdgeInsets.symmetric(horizontal: 0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        '',
                        style: TextStyle(fontSize: 16.0, color: Colors.white),
                      ),
                      Row(
                        children: [
                          if (Platform.isLinux || Platform.isWindows)
                            Material(
                              color: Colors.transparent,
                              child: InkWell(
                                onTap: () {
                                  windowManager.minimize();
                                },
                                child: Container(
                                  width: 30.0,
                                  height: 30.0,
                                  alignment: Alignment.center,
                                  child: const Icon(
                                    Icons.horizontal_rule,
                                    size: 14.0,
                                  ),
                                ),
                              ),
                            ),
                          if (Platform.isLinux || Platform.isWindows)
                            Material(
                              color: Colors.transparent,
                              child: InkWell(
                                onTap: () async {
                                  bool isMaximized =
                                      await windowManager.isMaximized();
                                  if (isMaximized) {
                                    windowManager.restore();
                                  } else {
                                    windowManager.maximize();
                                  }
                                },
                                child: Container(
                                  width: 30.0,
                                  height: 30.0,
                                  alignment: Alignment.center,
                                  child: const Icon(
                                    Icons.crop_square,
                                    size: 14.0,
                                  ),
                                ),
                              ),
                            ),
                          if (Platform.isLinux || Platform.isWindows)
                            Material(
                              color: Colors.transparent,
                              child: InkWell(
                                onTap: () {
                                  windowManager.hide();
                                },
                                hoverColor:
                                    const Color.fromARGB(255, 208, 24, 11)
                                        .withOpacity(0.8),
                                child: Container(
                                  width: 30.0,
                                  height: 30.0,
                                  alignment: Alignment.center,
                                  child: const Icon(
                                    Icons.close,
                                    size: 15.0,
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Positioned(
              top: -80, 
              left: 0,
              right: 0,
              bottom: -10,
              child: Container(
                height: MediaQuery.of(context).size.height, 
                child: DeviceScreen(
                  onDeviceSelected: (deviceInfo, isHistory) {
                   
                  },
                  onViewConnectInfo: () => Navigator.push(
                    context,
                    CupertinoPageRoute(
                      builder: (context) => const PairCodeScreen(),
                    ),
                  ),
                  onGoManualAdd: () => Navigator.push(
                    context,
                    CupertinoPageRoute(
                      builder: (context) => const AddDeviceScreen(),
                    ),
                  ),
                ),
              ),
            ),
            Align(
              alignment: Alignment.bottomCenter,
              child: Container(
                height: 70,
                width: double.infinity, 
                color: Theme.of(context).flixColors.background.secondary, 
                padding: const EdgeInsets.all(0.0),
                child: GestureDetector(
                  onTap: () async {
                    await _restoreWindowSize();
                    await Future.delayed(const Duration(milliseconds: 100));
                    await _centerWindow(); 
                    Navigator.pop(context);
                  },
                  child: Center(
                    child: Text(
                      '打开主界面',
                      style: TextStyle(
                        color: Theme.of(context).flixColors.text.secondary,
                      ), 
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
