import 'dart:io';

import 'package:android_intent/android_intent.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flix/domain/log/flix_log.dart';
import 'package:flix/presentation/widgets/permission/permission_bottom_sheet.dart';
import 'package:flix/utils/permission/flix_permission_tape.dart';
import 'package:flutter/cupertino.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:url_launcher/url_launcher.dart';

class FlixPermissionUtils {
  static Future<bool> checkAccessWifiNamePermission(
      BuildContext context) async {
    if (Platform.isAndroid || Platform.isIOS) {
      final permissions = [Permission.locationWhenInUse];
      bool isGranted = await isAllGranted(permissions);
      if (isGranted) return true;
      if (await FlixPermissionTape.isApplied(ApplyPermissionReason.wifiName))
        return false;
      await _showPermissionPromptPopup(
          context, '位置权限', '获取当前WiFi名称信息，需要获取设备的精确位置权限', () async {
        if (await isAnyPermanentlyDenied(permissions)) {
          await _openAppSettings();
        } else {
          await requestAllPermissions(permissions);
        }
      });
      FlixPermissionTape.applied(ApplyPermissionReason.wifiName);
      return await isAllGranted(permissions);
    } else {
      return true;
    }
  }

  static Future<bool> checkHotspotPermission(BuildContext? context) async {
    if (Platform.isAndroid) {
      // 33
      DeviceInfoPlugin deviceInfoPlugin = DeviceInfoPlugin();
      final androidInfo = await deviceInfoPlugin.androidInfo;
      if (androidInfo.version.sdkInt > 32) {
        return await checkNecessaryPermissions(
            context,
            [Permission.nearbyWifiDevices, Permission.locationWhenInUse],
            '缺少权限',
            '开启热点需要您授予访问附近设备和位置权限');
      } else {
        return await checkNecessaryPermissions(
            context, [Permission.locationWhenInUse], '位置权限', '开启热点需要您授予位置权限');
      }
      // <= 32, fine_location
    } else if (Platform.isIOS) {
      return await checkNecessaryPermissions(
          context, [Permission.locationWhenInUse], '位置权限', '开启热点需要您授予位置权限');
    } else {
      return true;
    }
  }

  static Future<bool> checkCameraPermission(BuildContext? context) async {
    if (Platform.isAndroid) {
      return await checkNecessaryPermissions(
          context, [Permission.camera], '相机权限', '扫一扫需要您授予相机权限');
    } else {
      return true;
    }
  }

  static Future<bool> checkStoragePermission(BuildContext? context,
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

  static Future<bool> checkStoragePermissionOnOldPlatform(
      BuildContext? context) async {
    return await checkNecessaryPermissions(
        context, [Permission.storage], '存储权限', '接收文件需要设备的存储权限');
  }

  static Future<bool> checkPhotosPermission(BuildContext context) async {
    if (Platform.isAndroid) {
      DeviceInfoPlugin deviceInfoPlugin = DeviceInfoPlugin();
      final androidInfo = await deviceInfoPlugin.androidInfo;
      if (androidInfo.version.sdkInt >= 33) {
        return await checkNecessaryPermissions(
            context,
            [Permission.photos, Permission.accessMediaLocation],
            '访问照片权限',
            '选择照片需要获取设备的访问照片权限');
      } else if (androidInfo.version.sdkInt >= 29) {
        return await checkNecessaryPermissions(
            context,
            [Permission.storage, Permission.accessMediaLocation],
            '访问照片权限',
            '选择照片需要获取设备的访问照片权限');
      } else {
        return await checkStoragePermissionOnOldPlatform(context);
      }
    } else if (Platform.isIOS) {
      return await checkNecessaryPermissions(
          context, [Permission.photos], '访问照片权限', '选择照片需要获取设备的访问照片权限');
    } else {
      return true;
    }
  }

  static Future<bool> checkVideosPermission(BuildContext context) async {
    if (Platform.isAndroid) {
      DeviceInfoPlugin deviceInfoPlugin = DeviceInfoPlugin();
      final androidInfo = await deviceInfoPlugin.androidInfo;
      if (androidInfo.version.sdkInt >= 33) {
        return await checkNecessaryPermissions(
            context,
            [Permission.videos, Permission.accessMediaLocation],
            '访问视频权限',
            '选择视频需要获取设备的访问视频权限');
      } else if (androidInfo.version.sdkInt >= 29) {
        return await checkNecessaryPermissions(
            context,
            [Permission.storage, Permission.accessMediaLocation],
            '访问视频权限',
            '选择视频需要获取设备的访问视频权限');
      } else {
        return await checkStoragePermissionOnOldPlatform(context);
      }
    } else if (Platform.isIOS) {
      return await checkNecessaryPermissions(
          context, [Permission.photos], '访问视频权限', '选择视频需要获取设备的访问视频权限');
    } else {
      return true;
    }
  }

  static Future<bool> checkPermissions(
      BuildContext? context, List<Permission> permissions) async {
    return await requestAllPermissions(permissions);
  }

  static Future<bool> checkNecessaryPermissions(BuildContext? context,
      List<Permission> permissions, String title, String subTitle) async {
    return await _checkNecessaryPermissions(
        context, permissions, title, subTitle);
  }

  static Future<bool> _checkNecessaryPermissions(BuildContext? context,
      List<Permission> permissions, String title, String subTitle) async {
    if (Platform.isAndroid || Platform.isIOS || Platform.isWindows) {
      try {
        // bool isGranted = await isAllGranted(permissions);

        // if (isGranted) {
        //   return true;
        // }
        //
        // bool isPermanentlyDenied = await isAnyPermanentlyDenied(permissions);
        //
        // // 无权限，但未禁止申请，直接申请
        // if (!isGranted && !isPermanentlyDenied) {
        bool isGranted = await requestAllPermissions(permissions);
        // }

        // isGranted = await isAllGranted(permissions);
        // talker.debug('storage permission to $isGranted');

        if (!isGranted) {
          talker.error('$permissions permission permanently denied');
          if (context != null) {
            await _showPermissionPromptPopup(context, title, subTitle,
                () async {
              await _openAppSettings();
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

  static Future<void> _showPermissionPromptPopup(BuildContext context,
      String title, String subTitle, Future<void> Function() onConfirm) async {
    await showCupertinoModalPopup(
        context: context,
        builder: (context) {
          return PermissionBottomSheet(
              title: title, subTitle: subTitle, onConfirm: onConfirm);
        });
  }

  static Future<bool> requestAllPermissions(
      List<Permission> permissions) async {
    for (var permission in permissions) {
      var permissionStatus = await permission.request();
      talker.debug('permission permissionStatus $permissionStatus');
      if (!permissionStatus.isGranted) return false;
    }
    return true;
  }

  static Future<bool> isAnyPermanentlyDenied(
      List<Permission> permissions) async {
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

  static Future<bool> isAllGranted(List<Permission> permissions) async {
    bool isGranted = true;

    for (var permission in permissions) {
      isGranted = isGranted & await permission.isGranted;

      talker.debug(
          'permission: $permission to $isGranted, isDenied: ${await permission.isDenied}, isPermanentlyDenied: ${await permission.isPermanentlyDenied}, isRestricted: ${await permission.isRestricted}, isLimited: ${await permission.isLimited}, isProvisional: ${await permission.isProvisional}');
      if (!isGranted) {
        break;
      }
    }
    return isGranted;
  }

  static Future<void> _openAppSettings() async {
    if (Platform.isAndroid) {
      await _openAndroidAppSettings();
    } else if (Platform.isIOS) {
      await _openIosAppSettings();
    }
  }

  static Future<void> _openAndroidAppSettings() async {
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

  static Future<void> _openIosAppSettings() async {
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
}
