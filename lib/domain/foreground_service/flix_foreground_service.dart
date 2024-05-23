
import 'dart:async';
import 'dart:io';
import 'dart:isolate';
import 'dart:ui';

import 'package:flix/domain/lifecycle/AppLifecycle.dart';
import 'package:flutter_foreground_task/flutter_foreground_task.dart';

// The callback function should always be a top-level function.
@pragma('vm:entry-point')
void startCallback() {
  // The setTaskHandler function must be called to handle the task in the background.
  FlutterForegroundTask.setTaskHandler(FirstTaskHandler());
}

class FirstTaskHandler extends TaskHandler {

  @override
  void onStart(DateTime timestamp, SendPort? sendPort) async {
    // TODO
  }

  @override
  void onRepeatEvent(DateTime timestamp, SendPort? sendPort) async {

  }

  @override
  void onDestroy(DateTime timestamp, SendPort? sendPort) async {
  }
}

class FlixForegroundService extends LifecycleListener {
  ReceivePort? _receivePort;


  void init() {
    FlutterForegroundTask.init(
      androidNotificationOptions: AndroidNotificationOptions(
        foregroundServiceType: AndroidForegroundServiceType.SPECIAL_USE,
        channelId: 'foreground_service',
        channelName: '文件传输',
        channelDescription: '文件传输提醒',
        channelImportance: NotificationChannelImportance.HIGH,
        priority: NotificationPriority.HIGH,
        iconData: const NotificationIconData(
          resType: ResourceType.mipmap,
          resPrefix: ResourcePrefix.ic,
          name: 'launcher',
        ),
        // buttons: [
        //   const NotificationButton(id: 'sendButton', text: 'Send'),
        //   const NotificationButton(id: 'testButton', text: 'Test'),
        // ],
      ),
      iosNotificationOptions: const IOSNotificationOptions(
        showNotification: true,
        playSound: false,
      ),
      foregroundTaskOptions: const ForegroundTaskOptions(
        interval: 5000,
        isOnceEvent: true,
        autoRunOnBoot: false,
        allowWakeLock: true,
        allowWifiLock: true,
      ),
    );

  }

  Future<void> start() async {
    if (await FlutterForegroundTask.isAppOnForeground && !await FlutterForegroundTask.isRunningService) {
      await _requestPermissionForAndroid();
      await _startForegroundTask();
    }
  }

  Future<bool> stop() async {
    if (await FlutterForegroundTask.isRunningService) {
      return await _stopForegroundTask();
    }
    return true;
  }

  Future<void> _requestPermissionForAndroid() async {
    if (!Platform.isAndroid) {
      return;
    }

    // // Android 12 or higher, there are restrictions on starting a foreground service.
    // //
    // // To restart the service on device reboot or unexpected problem, you need to allow below permission.
    // if (!await FlutterForegroundTask.isIgnoringBatteryOptimizations) {
    //   // This function requires `android.permission.REQUEST_IGNORE_BATTERY_OPTIMIZATIONS` permission.
    //   await FlutterForegroundTask.requestIgnoreBatteryOptimization();
    // }

    // Android 13 and higher, you need to allow notification permission to expose foreground service notification.
    final NotificationPermission notificationPermissionStatus =
    await FlutterForegroundTask.checkNotificationPermission();
    if (notificationPermissionStatus != NotificationPermission.granted) {
      await FlutterForegroundTask.requestNotificationPermission();
    }
  }


  Future<bool> _startForegroundTask() async {
    // You can save data using the saveData function.
    await FlutterForegroundTask.saveData(key: 'customData', value: 'hello');

    // Register the receivePort before starting the service.
    final ReceivePort? receivePort = FlutterForegroundTask.receivePort;
    final bool isRegistered = _registerReceivePort(receivePort);
    if (!isRegistered) {
      print('Failed to register receivePort!');
      return false;
    }

    if (await FlutterForegroundTask.isRunningService) {
      return FlutterForegroundTask.restartService();
    } else {
      return FlutterForegroundTask.startService(
        notificationTitle: 'Flix正在运行',
        notificationText: 'Flix正在后台运行，以保证文件的正常传输',
        callback: startCallback,
      );
    }
  }

  bool _registerReceivePort(ReceivePort? newReceivePort) {
    if (newReceivePort == null) {
      return false;
    }

    _closeReceivePort();

    _receivePort = newReceivePort;
    _receivePort?.listen((data) {
      // TODO
    });

    return _receivePort != null;
  }

  void _closeReceivePort() {
    _receivePort?.close();
    _receivePort = null;
  }

  Future<bool> _stopForegroundTask() {
    return FlutterForegroundTask.stopService();
  }

  @override
  void onLifecycleChanged(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      start();
    }
  }
}

final flixForegroundService = FlixForegroundService();