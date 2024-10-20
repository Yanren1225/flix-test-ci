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

  void addListener(LifecycleListener listener) {
    _lifecycleListeners.add(listener);
  }

  void removeListener(LifecycleListener listener) {
    _lifecycleListeners.remove(listener);
  }

  void dispatchLifecycleEvent(AppLifecycleState lifecycleState) {
    talker.verbose('AppLifecycle $lifecycleState');
    _dispatch(lifecycleState);
  }

  void _dispatch(AppLifecycleState state) {
    for (var listener in _lifecycleListeners) {
      listener.onLifecycleChanged(state);
    }
  }

}

abstract class LifecycleListener {
  void onLifecycleChanged(AppLifecycleState state);
}


final appLifecycle = AppLifecycle();
