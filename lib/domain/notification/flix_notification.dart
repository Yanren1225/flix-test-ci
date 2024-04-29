import 'dart:async';
import 'dart:io';

import 'package:flix/domain/log/flix_log.dart';
import 'package:flix/model/notification/reception_notification.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:local_notifier/local_notifier.dart';

class FlixNotification {
  int id = 1;

  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();
  final receptionNotificationStream = StreamController<MessageNotification>();

  Future<void> init() async {
    if (Platform.isWindows) {
      await initWin();
    } else {
      await initOtherPlatforms();
    }
  }

  Future<void> initWin() async {
    await localNotifier.setup(
      appName: 'flix',
      // 参数 shortcutPolicy 仅适用于 Windows
      shortcutPolicy: ShortcutPolicy.requireCreate,
    );
  }

  Future<void> initOtherPlatforms() async {
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('ic_launcher');

    final DarwinInitializationSettings initializationSettingsDarwin =
        DarwinInitializationSettings(
            onDidReceiveLocalNotification: null,
            requestAlertPermission: true,
            requestBadgePermission: true,
            requestSoundPermission: true,
            requestCriticalPermission: true);
    final LinuxInitializationSettings initializationSettingsLinux =
        LinuxInitializationSettings(defaultActionName: 'Open notification');
    final InitializationSettings initializationSettings =
        InitializationSettings(
            android: initializationSettingsAndroid,
            iOS: initializationSettingsDarwin,
            macOS: initializationSettingsDarwin,
            linux: initializationSettingsLinux);
    await flutterLocalNotificationsPlugin.initialize(initializationSettings,
        onDidReceiveNotificationResponse: (NotificationResponse details) {
      switch (details.notificationResponseType) {
        case NotificationResponseType.selectedNotification:
          final receptionNotification =
              MessageNotification.fromJson(details.payload!);
          receptionNotificationStream.add(receptionNotification);
          break;
        case NotificationResponseType.selectedNotificationAction:
          talker.debug(
              'selectedNotificationAction, actionId: ${details.actionId}');
          break;
      }
    });
  }

  Future<bool> isAndroidNotificationPermissionGranted() async {
    if (Platform.isAndroid) {
      return await flutterLocalNotificationsPlugin
              .resolvePlatformSpecificImplementation<
                  AndroidFlutterLocalNotificationsPlugin>()
              ?.areNotificationsEnabled() ??
          false;
    }
    return true;
  }

  Future<bool> requestNotificationPermissions() async {
    if (Platform.isIOS) {
      return await flutterLocalNotificationsPlugin
              .resolvePlatformSpecificImplementation<
                  IOSFlutterLocalNotificationsPlugin>()
              ?.requestPermissions(
                alert: true,
                badge: true,
                sound: true,
              ) ??
          false;
    } else if (Platform.isMacOS) {
      return await flutterLocalNotificationsPlugin
              .resolvePlatformSpecificImplementation<
                  MacOSFlutterLocalNotificationsPlugin>()
              ?.requestPermissions(
                alert: true,
                badge: true,
                sound: true,
              ) ??
          false;
    } else if (Platform.isAndroid) {
      final AndroidFlutterLocalNotificationsPlugin? androidImplementation =
          flutterLocalNotificationsPlugin.resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>();

      final bool? grantedNotificationPermission =
          await androidImplementation?.requestNotificationsPermission();
      return grantedNotificationPermission ?? false;
    } else {
      return true;
    }
  }

  Future<void> createNotificationChannel() async {
    const AndroidNotificationChannel androidNotificationChannel =
        AndroidNotificationChannel(
      'message',
      'message',
      description: '消息通知',
    );
    await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(androidNotificationChannel);
  }

  Future<void> showTextNotification(
      String deviceName, String text, MessageNotification notification) async {
    if (Platform.isWindows) {
      // create new NotificationMessage instance with id, title, body, and images
      _showWindowsNotification(deviceName, text, notification);
    } else {
      AndroidNotificationDetails androidNotificationDetails =
          AndroidNotificationDetails('message', 'message',
              channelDescription: '消息通知',
              importance: Importance.max,
              priority: Priority.high,
              ticker: 'ticker',
              autoCancel: true,
              tag: notification.from);
      NotificationDetails notificationDetails =
          NotificationDetails(android: androidNotificationDetails);
      await flutterLocalNotificationsPlugin.show(
          id++, deviceName, text, notificationDetails,
          payload: notification.toJson());
    }
  }

  void _showWindowsNotification(
      String title, String body, MessageNotification messageNotification) {
    LocalNotification notification = LocalNotification(
      identifier: '$id',
      title: title,
      body: body,
    );
    notification.onShow = () {
    };
    notification.onClose = (closeReason) async {
      // Only supported on windows, other platforms closeReason is always unknown.
      switch (closeReason) {
        case LocalNotificationCloseReason.userCanceled:
          await notification.close();
          await notification.destroy();
          break;
        case LocalNotificationCloseReason.timedOut:
        // do something
          break;
        default:
      }
    };
    notification.onClick = () {
      receptionNotificationStream.add(messageNotification);
    };
    notification.show();
  }

  Future<void> showFileNotification(
      String deviceName, MessageNotification notification) async {
    if (Platform.isWindows) {
      // create new NotificationMessage instance with id, title, body, and images
      _showWindowsNotification("接收到一个新的文件", '来自$deviceName', notification);
    } else {
      AndroidNotificationDetails androidNotificationDetails =
          AndroidNotificationDetails('reception', 'reception',
              channelDescription: '通知新的文件',
              importance: Importance.max,
              priority: Priority.high,
              ticker: 'ticker',
              autoCancel: true,
              tag: notification.from);
      NotificationDetails notificationDetails =
          NotificationDetails(android: androidNotificationDetails);
      await flutterLocalNotificationsPlugin.show(
          id++, '接收到一个新的文件', '来自$deviceName', notificationDetails,
          payload: notification.toJson());
    }
  }

  Future<List<ActiveNotification>> getNotifications() async {
    try {
      return (await flutterLocalNotificationsPlugin.getActiveNotifications());
    } on UnimplementedError catch (e) {
      return <ActiveNotification>[];
    }
  }
}

final flixNotification = FlixNotification();
