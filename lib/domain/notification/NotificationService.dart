
import 'package:androp/domain/bubble_pool.dart';
import 'package:androp/domain/device/device_manager.dart';
import 'package:androp/model/notification/reception_notification.dart';
import 'package:androp/model/ship/primitive_bubble.dart';
import 'package:androp/model/ui_bubble/shared_file.dart';
import 'package:androp/utils/notification_utils.dart';

class NotificationService {
  final _bubblePool = BubblePool.instance;

  NotificationService._privateConstruct();

  static final NotificationService _instance =
      NotificationService._privateConstruct();

  static NotificationService get instance => _instance;

  void init() {
    _bubblePool.listen((bubble) {
      if (bubble.to == DeviceManager.instance.did &&
          bubble is PrimitiveFileBubble &&
          bubble.content.state == FileState.waitToAccepted) {
        createNotificationChannel();
        isAndroidNotificationPermissionGranted().then((granted) {
          if (granted) {
            showReceptionNotification(bubble);
          } else {
            requestNotificationPermissions().then((granted) {
              if (granted) {
                showReceptionNotification(bubble);
              }
            });
          }
        });
      }
    });
  }



  void showReceptionNotification(PrimitiveBubble bubble) {
    showNotification(
        DeviceManager.instance.getDeviceInfoById(bubble.from)?.name ?? "",
        ReceptionNotification(from: bubble.from, bubbleId: bubble.id));
  }
}
