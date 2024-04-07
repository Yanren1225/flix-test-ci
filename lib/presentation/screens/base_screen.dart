import 'dart:async';
import 'dart:io';

import 'package:android_intent/android_intent.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flix/domain/bubble_pool.dart';
import 'package:flix/domain/device/device_manager.dart';
import 'package:flix/domain/log/flix_log.dart';
import 'package:flix/model/ship/primitive_bubble.dart';
import 'package:flix/model/ui_bubble/shared_file.dart';
import 'package:flix/presentation/widgets/permission/permission_bottom_sheet.dart';
import 'package:flutter/cupertino.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:permission_handler/permission_handler.dart';

var isCheckingPermission = false;

abstract class BaseScreenState<T extends StatefulWidget> extends State<T> {
  StreamSubscription<PrimitiveBubble>? subscription = null;

  @override
  void initState() {
    super.initState();
    _checkPermission();
  }

  Future<void> _checkPermission() async {
    if (Platform.isAndroid) {
      DeviceInfoPlugin deviceInfoPlugin = DeviceInfoPlugin();
      final androidInfo = await deviceInfoPlugin.androidInfo;
      if (androidInfo.version.sdkInt <= 29) {
        subscription = BubblePool.instance.listen((bubble) async {
          if (mounted &&
              bubble.to == DeviceManager.instance.did &&
              bubble is PrimitiveFileBubble &&
              bubble.content.state == FileState.waitToAccepted) {
            if (!isCheckingPermission) {
              isCheckingPermission = true;
              await checkStoragePermission(context);
              isCheckingPermission = false;
            } else {
              talker.debug('isCheckingPermission, ignore this request');
            }
          }
        });
      }
    }
  }

  @override
  void dispose() {
    subscription?.cancel();
    super.dispose();
  }
}

Future<bool> checkStoragePermission(BuildContext context) async {
  return await checkPermission(context, [Permission.storage], '存储权限', '接收文件需要设备的存储权限');
}

Future<bool> checkPhotosPermission(BuildContext context) async {
  return await checkPermission(context, [Permission.photos], '访问照片权限', '选择照片需要获取设备的访问照片权限');
}

Future<bool> checkVideosPermission(BuildContext context) async {
  return await checkPermission(context, [Permission.videos], '访问视频权限', '选择视频需要获取设备的访问视频权限');
}

Future<bool> checkPermission(BuildContext context, List<Permission> permissions, String title, String subTitle) async {
  return await _checkPermission(context, permissions, title, subTitle);
}

Future<bool> _checkPermission(BuildContext context, List<Permission> permissions, String title, String subTitle, {int requestCount = 0}) async {
  if (Platform.isAndroid) {

    bool isGranted = await isAllGranted(permissions);

    if (isGranted) {
      return true;
    }

    bool isPermanentlyDenied = await isAnyPermanentlyDenied(permissions);

    // 无权限，但未禁止申请，直接申请
    if (!isGranted && !isPermanentlyDenied) {
      isGranted = await requestAllPermissions(permissions);
    }

    // isGranted = await isAllGranted(permissions);
    // talker.debug('storage permission to $isGranted');

    if (!isGranted) {
      talker.error('$permissions permission permanently denied');
      await showCupertinoModalPopup(
          context: context,
          builder: (_context) {
            return PermissionBottomSheet(title: title, subTitle: subTitle, onConfirm: () async {
              if (requestCount >= 2 || await isAnyPermanentlyDenied(permissions)) {
                await _openAppSettings();
              } else {
                await _checkPermission(context, permissions, title, subTitle, requestCount: ++requestCount);
              }
            });
          });
      return false;
    }
    return true;
  }

  return true;
}

Future<bool> requestAllPermissions(List<Permission> permissions) async {
  for (var permission in permissions) {
    var permissionStatus = await permission.request();
    if (!permissionStatus.isGranted) return  false;
    talker.debug(
        'permission permissionStatus $permissionStatus');
  }
  return true;
}

Future<bool> isAnyPermanentlyDenied(List<Permission> permissions) async {
  bool isPermanentlyDenied = false;

  for (var permission in permissions) {
    isPermanentlyDenied =
    isPermanentlyDenied | await permission.isPermanentlyDenied;
    talker.debug(
        'permission: $permission isPermanentlyDenied $isPermanentlyDenied');
    if (isPermanentlyDenied) {
      break;
    }
  }
  return isPermanentlyDenied;
}


Future<bool> isAllGranted(List<Permission> storagePermission) async {
  bool isGranted = true;

  for (var permission in storagePermission) {
    isGranted = isGranted & await permission.isGranted;
    talker.debug('permission: $permission to $isGranted');
    if (!isGranted) {
      break;
    }
  }
  return isGranted;
}

Future<void> _openAppSettings() async {
  try {
    final info = await PackageInfo.fromPlatform();
    AndroidIntent intent = AndroidIntent(
      action: "android.settings.APPLICATION_DETAILS_SETTINGS",
      package: info.packageName,
      data: "package:${info.packageName}",
    );
    await intent.launch();
  } catch (e, stackTrace) {
    talker.error('failed to launch settings', e, stackTrace);
  }

}
