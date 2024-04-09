import 'package:flix/domain/bubble_pool.dart';
import 'package:flix/domain/device/device_manager.dart';
import 'package:flix/domain/log/flix_log.dart';
import 'package:flix/domain/notification/BadgeService.dart';
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
      final notification =
          MessageNotification(from: bubble.from, bubbleId: bubble.id);
      if (bubble.to == DeviceManager.instance.did) {
        if (bubble is PrimitiveTextBubble) {
          notified(notification);
          requestPermission(() => showTextNotification(bubble, notification));
        } else if (bubble is PrimitiveFileBubble &&
            bubble.content.state == FileState.waitToAccepted) {
          notified(notification);
          requestPermission(() => showFileNotification(bubble, notification));
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
        }).catchError((error) {
          talker.error('requestNotificationPermissions error', error);
        });
      }
    });
  }

  void showTextNotification(
      PrimitiveTextBubble bubble, MessageNotification notification) {
    notifyUtils.showTextNotification(
        DeviceManager.instance.getDeviceInfoById(bubble.from)?.name ?? "",
        bubble.content,
        notification);
  }

  void showFileNotification(
      PrimitiveBubble bubble, MessageNotification notification) {
    notifyUtils.showFileNotification(
        DeviceManager.instance.getDeviceInfoById(bubble.from)?.name ?? "",
        notification);
  }

  void notified(MessageNotification notification) {
    BadgeService.instance.addBadge(notification);
    Future.delayed(
        const Duration(seconds: 1),
        () => onNotificated.forEach((element) {
              element();
            }));
  }

  void addOnNotificatedListener(VoidCallback callback) {
    onNotificated.add(callback);
  }

  void removeOnNotificatedListener(VoidCallback callback) {
    onNotificated.remove(callback);
  }
}
