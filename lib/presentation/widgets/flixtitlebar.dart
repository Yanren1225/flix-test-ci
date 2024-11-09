import 'package:flix/design_widget/design_blue_round_button.dart';
import 'package:flix/theme/theme_extensions.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:window_manager/window_manager.dart';
import 'dart:io';

class FlixTitleBar extends StatelessWidget {
  const FlixTitleBar({Key? key}) : super(key: key);

   Future<void> _handleTap() async {
    final prefs = await SharedPreferences.getInstance();
    bool isDirectExitEnabled = prefs.getBool('direct_exit') ?? true; 
    if (isDirectExitEnabled) {
      await windowManager.hide();
    } else {
      exit(0);
    }
  }
  
  @override
  Widget build(BuildContext context) {
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
                          bool isMaximized = await windowManager.isMaximized();
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
                          _handleTap();
                        },
                        hoverColor: const Color.fromARGB(255, 208, 24, 11).withOpacity(0.8),
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
    );
  }
}
