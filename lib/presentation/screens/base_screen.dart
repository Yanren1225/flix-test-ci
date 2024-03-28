import 'dart:async';
import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:flix/domain/bubble_pool.dart';
import 'package:flix/domain/device/device_manager.dart';
import 'package:flix/domain/log/flix_log.dart';
import 'package:flix/model/ship/primitive_bubble.dart';
import 'package:flix/model/ui_bubble/shared_file.dart';
import 'package:flix/presentation/widgets/permission/permission_bottom_sheet.dart';
import 'package:flutter/cupertino.dart';
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
      // if (androidInfo.version.sdkInt <= 29) {
        subscription = BubblePool.instance.listen((bubble) async {
          if (mounted &&
              bubble.to == DeviceManager.instance.did &&
              bubble is PrimitiveFileBubble &&
              bubble.content.state == FileState.waitToAccepted) {
            if (!isCheckingPermission) {
              isCheckingPermission = true;
              await checkStoragePermission(context, bubble);
              isCheckingPermission = false;
            } else {
              talker.debug('isCheckingPermission, ignore this request');
            }

          }
        });
      // }
    }
  }

  @override
  void dispose() {
    subscription?.cancel();
    super.dispose();
  }
}

Future<void> checkStoragePermission(
    BuildContext context, PrimitiveBubble<dynamic> bubble) async {
  if (Platform.isAndroid) {
    var isGranted = await Permission.storage.isGranted;

    if (isGranted) {
      return;
    }

    final isPermanentlyDenied = await Permission.storage.isPermanentlyDenied;

    // 无权限，但未禁止申请，直接申请
    if (!isGranted && !isPermanentlyDenied) {
        var permissionStatus = await Permission.storage.request();
        talker
            .debug('_receiveFile permission permissionStatus $permissionStatus');

    }

    isGranted = await Permission.storage.isGranted;
    talker.debug('storage permission to $isGranted');

    // 申请后仍然没有权限，弹窗提示
    if (!isGranted) {
      talker.error('storage permission permanently denied');
      await showCupertinoModalPopup(
          context: context,
          builder: (context) {
            return PermissionBottomSheet();
          });
    }
  }
}
