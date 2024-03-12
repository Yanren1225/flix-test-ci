import 'package:flix/domain/bubble_pool.dart';
import 'package:flix/domain/device/device_manager.dart';
import 'package:flix/model/notification/reception_notification.dart';
import 'package:flix/model/ship/primitive_bubble.dart';
import 'package:flix/model/ui_bubble/shared_file.dart';
import 'package:flix/utils/notification_utils.dart' as notifyUtils;
import 'package:flutter/cupertino.dart';

class NotificationService {
  final _bubblePool = BubblePool.instance;

  NotificationService._privateConstruct();

  static final NotificationService _instance =
      NotificationService._privateConstruct();

  static NotificationService get instance => _instance;

  final onNotificated = <VoidCallback>[];

  void init() {
    _bubblePool.listen((bubble) {
      if (bubble.to == DeviceManager.instance.did) {
        if (bubble is PrimitiveTextBubble) {
          requestPermission(() => showTextNotification(bubble));
        } else if (bubble is PrimitiveFileBubble &&
            bubble.content.state == FileState.waitToAccepted) {
          requestPermission(() => showFileNotification(bubble));
        }
      }
    });
  }

  void requestPermission(VoidCallback callback) {
    notifyUtils.createNotificationChannel();
    notifyUtils.isAndroidNotificationPermissionGranted().then((granted) {
      if (granted) {
        callback();
      } else {
        notifyUtils.requestNotificationPermissions().then((granted) {
          if (granted) {
            callback();
          }
        });
      }
    });
  }

  void showTextNotification(PrimitiveTextBubble bubble) {
    notifyUtils.showTextNotification(
        DeviceManager.instance.getDeviceInfoById(bubble.from)?.name ?? "", bubble.content,
        MessageNotification(from: bubble.from, bubbleId: bubble.id));
    notified();
  }

  void showFileNotification(PrimitiveBubble bubble) {
    notifyUtils.showFileNotification(
        DeviceManager.instance.getDeviceInfoById(bubble.from)?.name ?? "",
        MessageNotification(from: bubble.from, bubbleId: bubble.id));
    notified();
  }

  void notified() {
    onNotificated.forEach((element) {
      element();
    });
  }

  void addOnNotificatedListener(VoidCallback callback) {
    onNotificated.add(callback);
  }

  void removeOnNotificatedListener(VoidCallback callback) {
    onNotificated.remove(callback);
  }
}
