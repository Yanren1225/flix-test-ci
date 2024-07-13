import 'dart:async';

import 'package:clipboard_watcher/clipboard_watcher.dart';
import 'package:flix/domain/constants.dart';
import 'package:flix/domain/log/flix_log.dart';
import 'package:flix/domain/ship_server/ship_service_proxy.dart';
import 'package:flutter/services.dart';

class FlixClipboardManager with ClipboardListener {

  static const clipboardChannel = MethodChannel("com.ifreedomer.flix/clipboard");

  Future<dynamic> foregroundMethodReceive(MethodCall methodCall) async{
    talker.debug("foregroundMethodReceive method ${methodCall.method}  args = ${methodCall.arguments}");
    switch (methodCall.method) {
      case 'return_send_clipboard':
        shipService.dispatcherClipboard(methodCall.arguments);
        break;
    }
  }

  FlixClipboardManager._privateConstruct();
  bool isAlive = false;
  static FlixClipboardManager get instance => _instance;
  static final FlixClipboardManager _instance =
      FlixClipboardManager._privateConstruct();



  void startWatcher() {
    isAlive = true;
    clipboardWatcher.addListener(this);
    clipboardWatcher.start();
    clipboardChannel.setMethodCallHandler(foregroundMethodReceive);
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
      return;
    }
    talker.debug(
        "onClipboardChanged  text = ${newClipboardData.text.toString()}");
    print(newClipboardData.text ?? '');
    shipService.dispatcherClipboard(newClipboardData.text.toString());
  }
}
