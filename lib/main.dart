import 'dart:async';
import 'dart:developer';
import 'dart:io';

import 'package:androp/domain/androp_context.dart';
import 'package:androp/domain/device/device_manager.dart';
import 'package:androp/domain/ship_server/ship_service.dart';
import 'package:androp/model/notification/reception_notification.dart';
import 'package:androp/network/multicast_client_provider.dart';
import 'package:androp/presentation/screens/concert_screen.dart';
import 'package:androp/presentation/screens/devices_screen.dart';
import 'package:androp/setting/setting_provider.dart';
import 'package:androp/utils/device/device_utils.dart';
import 'package:androp/utils/iterable_extension.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:provider/provider.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

int id = 1;
final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
FlutterLocalNotificationsPlugin();
final receptionNotificationStream = StreamController<ReceptionNotification>();

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  ShipService.instance.startShipServer();

  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent, // 设置为透明
        statusBarBrightness: Brightness.dark, // 在状态栏上的图标和文字颜色为深色
        statusBarIconBrightness: Brightness.dark),
  );

  await _initNotification();

  runApp(MultiProvider(
    providers: [
      ChangeNotifierProvider(create: (_) => SettingProvider()),
      ChangeNotifierProvider<MultiCastClientProvider>(
          create: (_) => MultiCastClientProvider())
    ],
    child: const MyApp(),
  ));
}

Future<void> _initNotification() async {
// initialise the plugin. app_icon needs to be a added as a drawable resource to the Android head project
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
  final InitializationSettings initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsDarwin,
      macOS: initializationSettingsDarwin,
      linux: initializationSettingsLinux);
  await flutterLocalNotificationsPlugin.initialize(initializationSettings,
      onDidReceiveNotificationResponse: (NotificationResponse details) {
        switch (details.notificationResponseType) {
          case NotificationResponseType.selectedNotification:
            final receptionNotification = ReceptionNotification.fromJson(
                details.payload!);
            receptionNotificationStream.add(receptionNotification);
            break;
          case NotificationResponseType.selectedNotificationAction:
            break;
        }
      });
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<StatefulWidget> createState() => MyAppState();
}

class MyAppState extends State<MyApp> {
  bool _notificationsEnabled = false;

  @override
  void initState() {
    super.initState();
    receptionNotificationStream.stream.listen((receptionNotification) {
      final deviceModal = DeviceManager.instance.deviceList.find((
          element) => element.fingerprint == receptionNotification.from);
      if (deviceModal != null) {
        Navigator.of(context).push(MaterialPageRoute(builder: (context) {
          return ConcertScreen(deviceInfo: deviceModal.toDeviceInfo());
        }));
      } else {
        log('can\'t find device by id: ${receptionNotification.from}');
      }
    });
  }

  @override
  void dispose() {
    receptionNotificationStream.close();
    super.dispose();
  }




  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => AndropContext(),
      child: MaterialApp(
        title: 'Androp',
        theme: ThemeData(
          // This is the theme of your application.
          //
          // TRY THIS: Try running your application with "flutter run". You'll see
          // the application has a purple toolbar. Then, without quitting the app,
          // try changing the seedColor in the colorScheme below to Colors.green
          // and then invoke "hot reload" (save your changes or press the "hot
          // reload" button in a Flutter-supported IDE, or press "r" if you used
          // the command line to start the app).
          //
          // Notice that the counter didn't reset back to zero; the application
          // state is not lost during the reload. To reset the state, use hot
          // restart instead.
          //
          // This works for code too, not just values: Most code changes can be
          // tested with just a hot reload.
          colorScheme: const ColorScheme.light(
              primary: Color.fromRGBO(0, 122, 255, 1), onPrimary: Colors.white),
          useMaterial3: true,
        ),
        home: const MyHomePage(title: 'Flutter Demo Home Page'),
      ),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  var selectedIndex = 0;

  void setSelectedIndex(int index) {
    setState(() {
      selectedIndex = index;
    });
  }

  Color getColor(int index, int selectedIndex) {
    return index == selectedIndex
        ? Colors.black
        : const Color.fromRGBO(60, 60, 67, 0.3);
  }

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return Scaffold(
      backgroundColor: const Color.fromRGBO(247, 247, 247, 1),
      body: DeviceScreen(
        key: GlobalKey(),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: [
          BottomNavigationBarItem(
              icon: SvgPicture.asset(
                'assets/images/ic_share.svg',
                colorFilter: ColorFilter.mode(
                    getColor(0, selectedIndex), BlendMode.srcIn),
              ),
              label: '互传'),
          BottomNavigationBarItem(
              icon: SvgPicture.asset(
                'assets/images/ic_config.svg',
                colorFilter: ColorFilter.mode(
                    getColor(1, selectedIndex), BlendMode.srcIn),
              ),
              label: '配置'),
          BottomNavigationBarItem(
              icon: SvgPicture.asset(
                'assets/images/ic_help.svg',
                colorFilter: ColorFilter.mode(
                    getColor(2, selectedIndex), BlendMode.srcIn),
              ),
              label: '帮助'),
        ],
        currentIndex: selectedIndex,
        selectedItemColor: Colors.black,
        unselectedItemColor: const Color.fromRGBO(60, 60, 67, 0.3),
        selectedFontSize: 10,
        unselectedFontSize: 10,
        selectedLabelStyle: const TextStyle(fontWeight: FontWeight.w500),
        unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w500),
        backgroundColor: Colors.white,
        elevation: 0,
        onTap: (value) => setSelectedIndex(value),
      ),
    );
  }
}
