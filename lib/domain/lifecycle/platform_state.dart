import 'dart:io';

import 'package:flix/domain/log/flix_log.dart';
import 'package:flutter_desktop_sleep/flutter_desktop_sleep.dart';

enum PlatformState {
  sleep,
  wokeUp
}

abstract class PlatformStateListener {
  void onPlatformStateChanged(PlatformState state);
}

class PlatformStateDispatcher {
  final List<PlatformStateListener> _listeners = [];

  PlatformStateDispatcher._private() {
    if (Platform.isWindows) {
      FlutterDesktopSleep flutterDesktopSleep = FlutterDesktopSleep();
      flutterDesktopSleep.setWindowSleepHandler((String? s) async {
        talker.info('Platform state: $s');
        if (s != null) {
          // autoClockOff(note: s, shouldThread: false, shouldOn: true);
          if (s == 'sleep') {
            dispatch(PlatformState.sleep);
          } else if (s == 'woke_up') {
            dispatch(PlatformState.wokeUp);
          } else if (s == 'terminate_app') {
            // await autoClockOff(
            //     note: 'App Terminate', shouldThread: false, shouldOn: false);
            // flutterDesktopSleep.terminateApp();
          }
        }
      });
    }
  }

  void addListener(PlatformStateListener listener) {
    _listeners.add(listener);
  }

  void removeListener(PlatformStateListener listener) {
    _listeners.remove(listener);
  }

  void dispatch(PlatformState state) {
    _listeners.forEach((listener) {
      listener.onPlatformStateChanged(state);
    });
  }
}

final platformStateDispatcher = PlatformStateDispatcher._private();