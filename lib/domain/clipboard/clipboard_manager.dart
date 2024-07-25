import 'dart:async';
import 'dart:ui';
import 'dart:ui';
import 'dart:ui';

import 'package:clipboard_watcher/clipboard_watcher.dart';
import 'package:flix/domain/constants.dart';
import 'package:flix/domain/device/device_discover.dart';
import 'package:flix/domain/device/device_manager.dart';
import 'package:flix/domain/lifecycle/app_lifecycle.dart';
import 'package:flix/domain/log/flix_log.dart';
import 'package:flix/domain/ship_server/ship_service_proxy.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FlixClipboardManager  with ClipboardListener implements LifecycleListener  {
  static const clipboardChannelName = "com.ifreedomer.flix/clipboard";
  static const clipboardChannel = MethodChannel(clipboardChannelName);


  static const String keyIsFromNotification = "is_from_notification";
  static const String tag = "FlixClipboardManager";
  FlixClipboardManager._privateConstruct();
  bool isAlive = false;
  static FlixClipboardManager get
  instance => _instance;
  static final FlixClipboardManager _instance =
      FlixClipboardManager._privateConstruct();

  void startWatcher() {
    isAlive = true;
    //每次从后台到前台会扫描设备，设备变化+从通知栏来，表示成功
    DeviceManager.instance.addDeviceListChangeListener(deviceListener);
    clipboardWatcher.addListener(this);
    clipboardWatcher.start();
  }

// and don't forget to clean up on your widget
  void stopWatcher() {
    isAlive = false;
    clipboardWatcher.removeListener(this);
    DeviceManager.instance.removeDeviceListChangeListener(deviceListener);
    clipboardWatcher.stop();
  }

  @override
  Future<void> onClipboardChanged() async {
    ClipboardData? newClipboardData =
        await Clipboard.getData(Clipboard.kTextPlain);
    if (newClipboardData == null) {
      return;
    }
    talker.debug(
        "onClipboardChanged  text = ${newClipboardData.text.toString()}");
    print(newClipboardData.text ?? '');
    shipService.dispatcherClipboard(newClipboardData.text.toString());
  }

  OnDeviceListChanged deviceListener = (device) async {
    bool? isFromNotification = await clipboardChannel.invokeMethod(keyIsFromNotification);
    talker.debug(tag,"deviceListener fromNotification = $isFromNotification");
    if (isFromNotification == true) {
      ClipboardData? newClipboardData =
          await Clipboard.getData(Clipboard.kTextPlain);
      talker.debug(tag,"deviceListener fromNotification clipText = ${newClipboardData?.text}");
      if (newClipboardData != null && newClipboardData.text != null) {
        shipService.dispatcherClipboard(newClipboardData.text.toString());
      }
    }
  };

  @override
  void onLifecycleChanged(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.resumed:
        //回到前台,会重新扫描设备，监听设备变化
      talker.debug(tag,"onLifecycleChanged resumed");
      DeviceManager.instance.addDeviceListChangeListener(deviceListener);
        break;
      case AppLifecycleState.paused:
        talker.debug(tag,"onLifecycleChanged paused");
        DeviceManager.instance.removeDeviceListChangeListener(deviceListener);
        break;
      default:
        break;
    }
  }
}
