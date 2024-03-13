import 'dart:ffi';
import 'dart:io';

import 'package:flix/main.dart';
import 'package:flix/model/notification/reception_notification.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

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

Future<void> showFileNotification(
    String deviceName, MessageNotification notification) async {
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

Future<List<ActiveNotification>> getNotifications() async {
  try {
    return (await flutterLocalNotificationsPlugin
        .getActiveNotifications());
  } on UnimplementedError catch (e) {
    return <ActiveNotification>[];
  }
}
