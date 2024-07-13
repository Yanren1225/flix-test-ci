import 'dart:ui';

import 'package:flix/domain/log/flix_log.dart';
import 'package:flutter/services.dart';

class AppLifecycle {
  AppLifecycle._privateConstructor();

  static final AppLifecycle _instance = AppLifecycle._privateConstructor();

  factory AppLifecycle() {
    return _instance;
  }

  final List<LifecycleListener> _lifecycleListeners = [];

  void init() {
    SystemChannels.lifecycle.setMessageHandler((msg) {
      _dispatchLifecycleEvent(msg);
      return Future(() => msg);
    });
  }

  void addListener(LifecycleListener listener) {
    _lifecycleListeners.add(listener);
  }

  void removeListener(LifecycleListener listener) {
    _lifecycleListeners.remove(listener);
  }

  void _dispatchLifecycleEvent(String? msg) {
    talker.verbose('AppLifecycle $msg');
    if (msg == 'AppLifecycleState.resumed') {
      for (var listener in _lifecycleListeners) {
        listener.onLifecycleChanged(AppLifecycleState.resumed);
      }
    } else if (msg == 'AppLifecycleState.inactive') {
      for (var listener in _lifecycleListeners) {
        listener.onLifecycleChanged(AppLifecycleState.inactive);
      }
    } else if (msg == 'AppLifecycleState.hide') {
      for (var listener in _lifecycleListeners) {
        listener.onLifecycleChanged(AppLifecycleState.hidden);
      }
    } else if (msg == 'AppLifecycleState.paused') {
      for (var listener in _lifecycleListeners) {
        listener.onLifecycleChanged(AppLifecycleState.paused);
      }
    } else if (msg == 'AppLifecycleState.detached') {
      for (var listener in _lifecycleListeners) {
        listener.onLifecycleChanged(AppLifecycleState.detached);
      }
    }

    void onAppResume() {
      print('App resume');
    }

    void onAppInactive() {
      print('App inactive');
    }
  }

}

abstract class LifecycleListener {
  void onLifecycleChanged(AppLifecycleState state);
}


final appLifecycle = AppLifecycle();
