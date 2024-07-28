import 'dart:io';

import 'package:android_intent/android_intent.dart';
import 'package:flix/domain/log/flix_log.dart';
import 'package:flutter/services.dart';
import 'package:flutter_app_installer/flutter_app_installer.dart';

import 'android_file_info.dart';

class AndroidUtils {

  static const FILE_CHANNEL = MethodChannel('com.ifreedomer.flix/file');

  static Future<FileInfo?> queryFileInfo(String uri) async {
    try {
      final Map infoMap = await FILE_CHANNEL.invokeMethod(
          "queryFileInfo", {"uri": uri});
      return FileInfo(
          name: infoMap['name'] ?? "",
          path: infoMap['path'] ?? "",
          size: int.parse(infoMap['size']),
          uri: infoMap['uri']??""
      );
    } catch (e, s) {
      talker.error("query file info failed", e, s);
      return null;
    }
  }

  static openSettings() async {
    if (Platform.isAndroid) {
      AndroidIntent intent = const AndroidIntent(
        action: 'android.settings.SETTINGS',
      );
      await intent.launch();
    }
  }

  static openWifiSettings() async {
    if (Platform.isAndroid) {
      AndroidIntent intent = const AndroidIntent(
        action: 'android.settings.WIFI_SETTINGS',
      );
      await intent.launch();
    }
  }

  static installApk(String path) async {
    try {
      // 请求安装权限
      final result = await FlutterAppInstaller().installApk(filePath: path);
      if (!result) {
        talker.error('install apk failed');
      }
      return result;
    } catch (e, stackTrace) {
      talker.error('install apk failed: ', e, stackTrace);
      return false;
    }
  }

  static launchGallery() async {
    try {
      if (Platform.isAndroid) {
        AndroidIntent intent = const AndroidIntent(
            action: 'android.intent.action.VIEW',
            type: 'vnd.android.cursor.dir/image'
        );
        await intent.launch();
      }
    } catch (e, s) {
      talker.error("launch gallery failed", e, s);
    }

  }

  static Future<bool> openFile(String path) async {
    if (Platform.isAndroid) {
      return await FILE_CHANNEL.invokeMethod("openFile", {"path": path});
    }
    return false;
  }
}
