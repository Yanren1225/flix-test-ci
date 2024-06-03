import 'dart:io';

import 'package:flutter/services.dart';

class PhysicalLock {
  static final LOCK_CHANNEL = MethodChannel('com.ifreedomer.flix/lock');

  static void acquirePhysicalLock() {
    acquireWakeLock();
    acquireWifiLock();
  }

  static void releasePhysicalLock() {
    releaseWifiLock();
    releaseWakeLock();
  }

  static void acquireWakeLock() {
    if (Platform.isAndroid) {
      LOCK_CHANNEL.invokeMethod("acquireWakeLock");
    }
  }

  static void releaseWakeLock() {
    if (Platform.isAndroid) {
      LOCK_CHANNEL.invokeMethod("releaseWakeLock");
    }
  }

  static void acquireWifiLock() {
    if (Platform.isAndroid) {
      LOCK_CHANNEL.invokeMethod("acquireWifiLock");
    }
  }

  static void releaseWifiLock() {
    if (Platform.isAndroid) {
      LOCK_CHANNEL.invokeMethod("releaseWifiLock");
    }
  }
}