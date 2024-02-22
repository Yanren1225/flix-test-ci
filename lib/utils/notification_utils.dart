import 'dart:ffi';
import 'dart:io';

import 'package:androp/main.dart';
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
        ) ?? false;
  } else if (Platform.isMacOS) {
    return await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            MacOSFlutterLocalNotificationsPlugin>()
        ?.requestPermissions(
          alert: true,
          badge: true,
          sound: true,
        ) ?? false;
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
    'reception',
    'reception',
    description: '通知新的文件',
  );
  await flutterLocalNotificationsPlugin
      .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>()
      ?.createNotificationChannel(androidNotificationChannel);
}

Future<void> showNotification(String content) async {
  const AndroidNotificationDetails androidNotificationDetails =
      AndroidNotificationDetails('reception', 'reception',
          channelDescription: '通知新的文件',
          importance: Importance.max,
          priority: Priority.high,
          ticker: 'ticker');
  const NotificationDetails notificationDetails =
      NotificationDetails(android: androidNotificationDetails);
  await flutterLocalNotificationsPlugin.show(
      id++, '收到一个图片', '来自Xiaomi 14', notificationDetails,
      payload: 'item x');
}
