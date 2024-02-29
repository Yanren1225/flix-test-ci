import 'dart:async';
import 'dart:developer';
import 'dart:io';

import 'package:anydrop/domain/androp_context.dart';
import 'package:anydrop/domain/device/device_manager.dart';
import 'package:anydrop/domain/notification/NotificationService.dart';
import 'package:anydrop/domain/ship_server/ship_service.dart';
import 'package:anydrop/model/device_info.dart';
import 'package:anydrop/model/notification/reception_notification.dart';
import 'package:anydrop/network/multicast_client_provider.dart';
import 'package:anydrop/presentation/screens/concert_screen.dart';
import 'package:anydrop/presentation/screens/devices_screen.dart';
import 'package:anydrop/presentation/screens/helps/help_screen.dart';
import 'package:anydrop/presentation/screens/settings/settings_screen.dart';
import 'package:anydrop/setting/setting_provider.dart';
import 'package:anydrop/utils/device/device_utils.dart';
import 'package:anydrop/utils/iterable_extension.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:modals/modals.dart';
import 'package:provider/provider.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:window_manager/window_manager.dart';

int id = 1;
final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();
final receptionNotificationStream = StreamController<ReceptionNotification>();

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  if (Platform.isMacOS || Platform.isLinux || Platform.isWindows) {
    await windowManager.ensureInitialized();
    windowManager.setMinimumSize(const Size(400, 400));
  }

  NotificationService.instance.init();
  ShipService.instance.startShipServer();
  DeviceManager.instance.init();

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
        final receptionNotification =
            ReceptionNotification.fromJson(details.payload!);
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
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => AndropContext(),
      child: MaterialApp(
        title: 'Androp',
        navigatorObservers: [modalsRouteObserver],
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
  DeviceInfo? selectedDevice;
  bool isLeaved = false;

  @override
  void initState() {
    super.initState();
    receptionNotificationStream.stream.listen((receptionNotification) {
      final deviceModal = DeviceManager.instance.deviceList
          .find((element) => element.fingerprint == receptionNotification.from);
      if (deviceModal != null) {
        if (_isOverMediumWidth()) {
          setSelectedIndex(0);
          setSelectedDevice(deviceModal.toDeviceInfo());
        } else {
          Navigator.push(context, MaterialPageRoute(builder: (context) {
            return ConcertScreen(
              deviceInfo: deviceModal.toDeviceInfo(),
              showBackButton: true,
            );
          }));
        }
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

  void setSelectedIndex(int index) {
    setState(() {
      selectedIndex = index;
    });
  }

  void setSelectedDevice(DeviceInfo? deviceInfo) {
    setState(() {
      selectedDevice = deviceInfo;
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
    if (_isOverMediumWidth()) {
      return WideLayout();
    } else {
      return NarrowLayout();
    }
  }

  bool _isOverMediumWidth() {
    return MediaQuery.of(context).size.width > 600;
  }

  Widget NarrowLayout() {
    // final deviceInfo = selectedDevice;
    // if (deviceInfo != null) {
    //   SchedulerBinding.instance.addPostFrameCallback((_) {
    //     if (!isLeaved) {
    //       isLeaved = true;
    //       Navigator.push(
    //           context,
    //           MaterialPageRoute(
    //               builder: (context) => ConcertScreen(
    //                     deviceInfo: deviceInfo,
    //                     showBackButton: true,
    //                   ))).then((value) => isLeaved = false);
    //     }
    //   });
    // }
    return Scaffold(
      backgroundColor: const Color.fromRGBO(247, 247, 247, 1),
      body: NarrowBody(),
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

  Widget NarrowBody() {
    switch (selectedIndex) {
      case 0:
        return DeviceScreen(
          onDeviceSelected: (deviceInfo) => Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => ConcertScreen(
                        deviceInfo: deviceInfo,
                        showBackButton: true,
                      ))),
        );
      case 1:
        return SettingsScreen();
      case 2:
        return HelpScreen();
      default:
        return Placeholder();
    }
  }

  Widget WideLayout() {
    return Scaffold(
      backgroundColor: const Color.fromRGBO(247, 247, 247, 1),
      body: Row(
        children: [
          NavigationRail(
            onDestinationSelected: (int index) {
              setSelectedIndex(index);
            },
            destinations: [
              NavigationRailDestination(
                  icon: SvgPicture.asset(
                    'assets/images/ic_share.svg',
                    colorFilter: ColorFilter.mode(
                        getColor(0, selectedIndex), BlendMode.srcIn),
                  ),
                  label: Text('互传')),
              NavigationRailDestination(
                  icon: SvgPicture.asset(
                    'assets/images/ic_config.svg',
                    colorFilter: ColorFilter.mode(
                        getColor(1, selectedIndex), BlendMode.srcIn),
                  ),
                  label: Text('配置')),
              NavigationRailDestination(
                  icon: SvgPicture.asset(
                    'assets/images/ic_help.svg',
                    colorFilter: ColorFilter.mode(
                        getColor(2, selectedIndex), BlendMode.srcIn),
                  ),
                  label: Text('帮助'))
            ],
            labelType: NavigationRailLabelType.all,
            useIndicator: false,
            groupAlignment: 0.0,
            extended: false,
            elevation: null,
            selectedIndex: selectedIndex,
            selectedIconTheme:
                const IconThemeData(size: 26, color: Colors.black),
            unselectedIconTheme: const IconThemeData(
                size: 26, color: Color.fromRGBO(60, 60, 67, 0.3)),
            selectedLabelTextStyle: TextStyle(
                color: Colors.black,
                fontSize: 12,
                fontWeight: FontWeight.normal),
            unselectedLabelTextStyle: TextStyle(
                color: Color.fromRGBO(60, 60, 67, 0.3),
                fontSize: 12,
                fontWeight: FontWeight.normal),
            backgroundColor: Colors.white,
          ),
          Flexible(child: secondPart(), flex: 1),
          Expanded(
            child: thirdPart(),
            flex: 2,
          )
        ],
      ),
    );
  }

  Widget secondPart() {
    switch (selectedIndex) {
      case 0:
        return DeviceScreen(
          onDeviceSelected: (deviceInfo) => setSelectedDevice(deviceInfo),
        );
      case 1:
        return SettingsScreen();
      case 2:
        return HelpScreen();
      default:
        return Placeholder();
    }
  }

  Widget thirdPart() {
    final deviceInfo = selectedDevice;

    if (deviceInfo != null) {
      return ConcertScreen(deviceInfo: deviceInfo, showBackButton: false);
    } else {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SvgPicture.asset('assets/images/img_placeholder.svg'),
            const SizedBox(
              height: 16,
            ),
            const Text(
              '请选择设备',
              style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.normal,
                  color: Colors.black),
            )
          ],
        ),
      );
    }
  }
}
