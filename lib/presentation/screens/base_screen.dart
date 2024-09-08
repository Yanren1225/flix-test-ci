import 'dart:async';
import 'dart:io';

import 'package:android_intent/android_intent.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flix/domain/bubble_pool.dart';
import 'package:flix/domain/device/device_profile_repo.dart';
import 'package:flix/domain/log/flix_log.dart';
import 'package:flix/model/ship/primitive_bubble.dart';
import 'package:flix/model/ui_bubble/shared_file.dart';
import 'package:flix/presentation/widgets/permission/permission_bottom_sheet.dart';
import 'package:flutter/cupertino.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:url_launcher/url_launcher.dart';

var isCheckingPermission = false;

abstract class BaseScreenState<T extends StatefulWidget> extends State<T> {
  StreamSubscription<PrimitiveBubble>? subscription;

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
              bubble.to == DeviceProfileRepo.instance.did &&
              (bubble is PrimitiveFileBubble ||
                  bubble is PrimitiveDirectoryBubble) &&
              bubble.content.state == FileState.waitToAccepted) {
            if (!isCheckingPermission) {
              isCheckingPermission = true;
              await checkStoragePermissionOnOldPlatform(context);
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

Future<bool> checkStoragePermission(BuildContext? context,
    {bool manageExternalStorage = false}) async {
  if (Platform.isAndroid) {
    DeviceInfoPlugin deviceInfoPlugin = DeviceInfoPlugin();
    final androidInfo = await deviceInfoPlugin.androidInfo;
    if (androidInfo.version.sdkInt >= 30) {
      if (manageExternalStorage) {
        if (await Permission.manageExternalStorage.isDenied) {
          await Permission.manageExternalStorage.request();
          return false;
        } else {
          return true;
        }
      } else {
        return true;
      }
    } else {
      return await checkStoragePermissionOnOldPlatform(context);
    }
  }
  return true;
}

Future<bool> checkStoragePermissionOnOldPlatform(BuildContext? context) async {
  return await checkPermission(
      context, [Permission.storage], '存储权限', '接收文件需要设备的存储权限');
}

Future<bool> checkPermission(BuildContext? context,
    List<Permission> permissions, String title, String subTitle) async {
  return await _checkPermission(context, permissions, title, subTitle);
}

Future<bool> _checkPermission(BuildContext? context,
    List<Permission> permissions, String title, String subTitle) async {
  if (Platform.isAndroid) {
    try {
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
        if (context != null) {
          await showCupertinoModalPopup(
              context: context,
              builder: (context) {
                return PermissionBottomSheet(
                    title: title,
                    subTitle: subTitle,
                    onConfirm: () async {
                      await _openAppSettings();
                    });
              });
        }

        return false;
      }
      return true;
    } catch (e, stackTrace) {
      talker.error('request permission: $permissions failed', e, stackTrace);
      return false;
    }
  }
  return true;
}

Future<bool> requestAllPermissions(List<Permission> permissions) async {
  for (var permission in permissions) {
    var permissionStatus = await permission.request();
    if (!permissionStatus.isGranted) return false;
    talker.debug('permission permissionStatus $permissionStatus');
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

Future<bool> isAllGranted(List<Permission> permissions) async {
  bool isGranted = true;

  for (var permission in permissions) {
    isGranted = isGranted & await permission.isGranted;
    talker.debug('permission: $permission to $isGranted');
    if (!isGranted) {
      break;
    }
  }
  return isGranted;
}

Future<void> _openAppSettings() async {
  if (Platform.isAndroid) {
    await _openAndroidAppSettings();
  } else if (Platform.isIOS) {
    await _openIosAppSettings();
  }
}

Future<void> _openAndroidAppSettings() async {
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

Future<void> _openIosAppSettings() async {
  try {
    const url = 'app-settings:';
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      print('无法打开应用设置页面');
    }
  } catch (e, stackTrace) {
    talker.error('failed to launch settings', e, stackTrace);
  }
}
