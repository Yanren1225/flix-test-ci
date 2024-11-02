import 'package:animations/animations.dart';
import 'package:flix/presentation/screens/intro/intro_welcome.dart';
import 'package:flix/presentation/screens/intro/intro_wifi.dart';
import 'package:flix/presentation/screens/intro/intro_permission.dart'; 
import 'package:flix/theme/theme_extensions.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:window_manager/window_manager.dart';
import 'dart:io' show Platform;


class IntroPage extends StatefulWidget {
  @override
  _IntroPageState createState() => _IntroPageState();
}

class _IntroPageState extends State<IntroPage> {
  bool showIntroWiFi = false; 
  bool showIntroPermission = false; 
  bool isForwardTransition = true;
  

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
            _buildWindowControls(),
          PageTransitionSwitcher(
          duration: const Duration(milliseconds: 300), 
          reverse: !isForwardTransition,
          transitionBuilder: (child, animation, secondaryAnimation) {
            return SharedAxisTransition(
              animation: animation,
              fillColor:Theme.of(context).flixColors.background.secondary, 
              secondaryAnimation: secondaryAnimation,
              transitionType: SharedAxisTransitionType.horizontal, 
            
                child: child,
              
            );
          },
            child: showIntroPermission
                ? IntroPermission(
                    key: const ValueKey('IntroPermission'),
                    onBackPressed: () => _switchToWiFiPage(isReturning: true),
                    onContinuePressed: _exitIntroPage,
                  )
                : showIntroWiFi
                    ? IntroWiFi(
                        key: const ValueKey('IntroWiFi'),
                        onBackPressed: () => _switchToWelcomePage(isReturning: true),
                        onContinuePressed: () => _switchToPermissionPage(isReturning: false),
                      )
                    : IntroWelcome(
                        key: const ValueKey('IntroWelcome'),
                        onExplorePressed: () => _switchToWiFiPage(isReturning: false),
                      ),
          ),
        ],
      ),
    );
  }



  Widget _buildWindowControls() {
    return Positioned(
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
            actions: _buildWindowActions(),
            backgroundColor: Colors.transparent,
            elevation: 0,
          ),
        ),
      ),
    );
  }

  List<Widget> _buildWindowActions() {
    return [
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
    ];
  }


  void _switchToWiFiPage({required bool isReturning}) {
    setState(() {
      isForwardTransition = !isReturning; 
      showIntroWiFi = true;
      showIntroPermission = false;
    });
  }

  void _switchToPermissionPage({required bool isReturning}) {
    setState(() {
      isForwardTransition = !isReturning; 
      showIntroPermission = true;
    });
  }

  void _switchToWelcomePage({required bool isReturning}) {
    setState(() {
      isForwardTransition = !isReturning; 
      showIntroWiFi = false;
      showIntroPermission = false;
    });
  }

  void _exitIntroPage() {
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
