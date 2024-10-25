import 'package:flix/presentation/screens/intro/intro_welcome.dart';
import 'package:flix/presentation/screens/intro/intro_wifi.dart';
import 'package:flix/presentation/screens/intro/intro_permission.dart'; 
import 'package:flix/theme/theme_extensions.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:window_manager/window_manager.dart';
import 'dart:io' show Platform;


class intropage extends StatefulWidget {
  @override
  _intropageState createState() => _intropageState();
}

class _intropageState extends State<intropage> {
  bool showIntroWiFi = false; 
  bool showIntroPermission = false; 

  @override
  void initState() {
    super.initState();
    _initSystemChrome(); 
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).flixColors.background.secondary, 
      body: Stack(
        children: [
          if (Platform.isMacOS || Platform.isLinux || Platform.isWindows)
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
                  child: AppBar(
                    automaticallyImplyLeading: false,
                    title: const Text(''),
                    actions: [
                      Material(
                        color: Colors.transparent,
                        child: InkWell(
                          customBorder: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(0),
                          ),
                          onTap: () {
                            windowManager.minimize();
                          },
                          child: const Padding(
                            padding: EdgeInsets.all(8.0),
                            child: Icon(
                              Icons.horizontal_rule,
                              size: 14.0,
                            ),
                          ),
                        ),
                      ),
                      Material(
                        color: Colors.transparent,
                        child: InkWell(
                          customBorder: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(0),
                          ),
                          onTap: () async {
                            bool isMaximized = await windowManager.isMaximized();
                            if (isMaximized) {
                              windowManager.restore();
                            } else {
                              windowManager.maximize();
                            }
                          },
                          child: const Padding(
                            padding: EdgeInsets.all(8.0),
                            child: Icon(
                              Icons.crop_square,
                              size: 14.0,
                            ),
                          ),
                        ),
                      ),
                      Material(
                        color: Colors.transparent,
                        child: InkWell(
                          customBorder: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(0),
                          ),
                          hoverColor: const Color.fromARGB(255, 208, 24, 11).withOpacity(0.8),
                          onTap: () {
                            windowManager.hide();
                          },
                          child: const Padding(
                            padding: EdgeInsets.all(8.0),
                            child: Icon(
                              Icons.close,
                              size: 15.0,
                            ),
                          ),
                        ),
                      ),
                    ],
                    backgroundColor: Colors.transparent,
                    elevation: 0,
                  ),
                ),
              ),
            ),
          showIntroPermission
              ? IntroPermission(
                  onBackPressed: _switchToWiFiPage,
                  onContinuePressed: _exitintropage, 
                )
              : showIntroWiFi
                  ? IntroWiFi(
                      onBackPressed: _switchToWelcomePage,
                      onContinuePressed: _switchToPermissionPage,
                    )
                  : IntroWelcome(onExplorePressed: _switchToWiFiPage),
        ],
      ),
    );
  }

  void _switchToWiFiPage() {
    setState(() {
      showIntroWiFi = true;
      showIntroPermission = false;
    });
  }

  void _switchToPermissionPage() {
    setState(() {
      showIntroPermission = true;
    });
  }

  void _switchToWelcomePage() {
    setState(() {
      showIntroWiFi = false;
      showIntroPermission = false;
    });
  }

  void _exitintropage() {
    Navigator.of(context).pop();
  }


  void _initSystemChrome() {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarBrightness: Brightness.light,
        systemStatusBarContrastEnforced: false,
        statusBarIconBrightness: Brightness.dark,
        systemNavigationBarColor: Colors.transparent,
        systemNavigationBarContrastEnforced: false,
        systemNavigationBarIconBrightness: Brightness.dark,
      ),
    );
  }
}
