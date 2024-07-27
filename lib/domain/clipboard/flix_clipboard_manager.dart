import 'dart:async';
import 'dart:ui';
import 'package:clipboard_watcher/clipboard_watcher.dart';
import 'package:flix/domain/device/device_discover.dart';
import 'package:flix/domain/device/device_manager.dart';
import 'package:flix/domain/lifecycle/app_lifecycle.dart';
import 'package:flix/domain/log/flix_log.dart';
import 'package:flix/domain/ship_server/ship_service_proxy.dart';
import 'package:flutter/services.dart';

class FlixClipboardManager  with ClipboardListener implements LifecycleListener {
  static const clipboardChannelName = "com.ifreedomer.flix/clipboard";
  static const clipboardChannel = MethodChannel(clipboardChannelName);

  static const String keyIsFromNotification = "is_from_notification";
  static const String tag = "FlixClipboardManager";
  FlixClipboardManager._privateConstruct();
  bool isAlive = false;
  String _lastText = "";
  static FlixClipboardManager get
  instance => _instance;
  static final FlixClipboardManager _instance =
      FlixClipboardManager._privateConstruct();

  OnDeviceListChanged? _deviceListChanged;

  void startWatcher() {
    isAlive = true;
    //每次从后台到前台会扫描设备，设备变化，感知同步剪贴板
    if(_deviceListChanged == null){
      _deviceListChanged = (devices){
        talker.debug(tag,"device change");
        onClipboardChanged();
      };
      DeviceManager.instance.addDeviceListChangeListener(_deviceListChanged!);
    }
    clipboardWatcher.addListener(this);
    clipboardWatcher.start();
  }

// and don't forget to clean up on your widget
  void stopWatcher() {
    isAlive = false;
    clipboardWatcher.removeListener(this);
    clipboardWatcher.stop();
  }

  @override
  Future<void> onClipboardChanged() async {
    ClipboardData? newClipboardData =
        await Clipboard.getData(Clipboard.kTextPlain);
    if (newClipboardData == null) {
      talker.debug(tag,"newClipboardData is null");
      return;
    }
    if(newClipboardData.text == _lastText){
      talker.debug(tag,"newClipboardData no new text");
      return;
    }
    talker.debug(tag,
        "onClipboardChanged  text = ${newClipboardData.text.toString()}");
    print(newClipboardData.text ?? '');
    shipService.dispatcherClipboard(newClipboardData.text.toString());
  }


  @override
  void onLifecycleChanged(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.resumed:
        //回到前台,延迟2s等界面焦点,再去同步剪贴板
        talker.debug(tag,"onLifecycleChanged resumed");
        Future.delayed(const Duration(milliseconds: 2000), () {
          //延时执行的代码
          talker.debug(tag,"onLifecycleChanged resumed onClipboardChanged");
          onClipboardChanged();
        });
        break;
      case AppLifecycleState.paused:
        talker.debug(tag,"onLifecycleChanged paused");
        break;
      default:
        break;
    }
  }
}
