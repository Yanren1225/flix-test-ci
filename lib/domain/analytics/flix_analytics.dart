import 'dart:io';

import 'package:firebase_analytics/firebase_analytics.dart';

class FlixAnalytics {
  FirebaseAnalytics? _backendAnalytics = null;

  FirebaseAnalytics? get _analytics {
    if (Platform.isAndroid || Platform.isIOS || Platform.isMacOS) {
      _backendAnalytics ??= FirebaseAnalytics.instance;
      return _backendAnalytics;
    } else {
      return null;
    }
  }

  FlixAnalytics._privateConstructor();

  void logAppOpen() {
    _analytics?.logAppOpen();
  }
}

final FlixAnalytics flixAnalytics = FlixAnalytics._privateConstructor();
