import 'dart:async';
import 'dart:io';

import 'package:chinese_font_library/chinese_font_library.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flix/domain/androp_context.dart';
import 'package:flix/domain/bubble_pool.dart';
import 'package:flix/domain/database/database.dart';
import 'package:flix/domain/device/device_discover.dart';
import 'package:flix/domain/device/device_manager.dart';
import 'package:flix/domain/device/device_profile_repo.dart';
import 'package:flix/domain/lifecycle/AppLifecycle.dart';
import 'package:flix/domain/log/flix_log.dart';
import 'package:flix/domain/log/persistence/log_persistence.dart';
import 'package:flix/domain/log/persistence/log_persistence_proxy.dart';
import 'package:flix/domain/notification/NotificationService.dart';
import 'package:flix/domain/notification/flix_notification.dart';
import 'package:flix/domain/ship_server/ship_service.dart';
import 'package:flix/domain/ship_server/ship_service_lifecycle_watcher.dart';
import 'package:flix/domain/ship_server/ship_service_proxy.dart';
import 'package:flix/domain/window/FlixWindowManager.dart';
import 'package:flix/model/device_info.dart';
import 'package:flix/network/multicast_client_provider.dart';
import 'package:flix/presentation/screens/concert/concert_screen.dart';
import 'package:flix/presentation/screens/devices_screen.dart';
import 'package:flix/presentation/screens/helps/about_us.dart';
import 'package:flix/presentation/screens/helps/help_screen.dart';
import 'package:flix/presentation/screens/pick_device_screen.dart';
import 'package:flix/presentation/screens/settings/settings_screen.dart';
import 'package:flix/presentation/widgets/flix_toast.dart';
import 'package:flix/setting/setting_provider.dart';
import 'package:flix/utils/device/device_utils.dart';
import 'package:flix/utils/device_info_helper.dart';
import 'package:flix/utils/iterable_extension.dart';
import 'package:flix/utils/meida/media_utils.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_svg/svg.dart';
import 'package:flutter_ume/flutter_ume.dart'; // UME framework
import 'package:flutter_ume_kit_console/flutter_ume_kit_console.dart'; // Show debugPrint
import 'package:flutter_ume_kit_ui/flutter_ume_kit_ui.dart'; // UI kits
import 'package:fluttertoast/fluttertoast.dart';
import 'package:launch_at_startup/launch_at_startup.dart';
import 'package:modals/modals.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:provider/provider.dart';
import 'package:share_handler/share_handler.dart';
import 'package:system_tray/system_tray.dart';
import 'package:window_manager/window_manager.dart';

import 'domain/notification/BadgeService.dart';
import 'firebase_options.dart';
import 'presentation/screens/base_screen.dart';

// final demoSplitViewKey = GlobalKey<NavigatorState>();
// final _leftKey = GlobalKey();

GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

bool needExitApp = false;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await logPersistence.init();
    await initFireBase();
    await initWindowManager();
    await initBootStartUp();
    await _initNotification();
    await initSystemManager();
    _initDatabase();
    final deviceInfo = await _initDeviceManager();
    _logAppContext(deviceInfo);
    _initAppLifecycle();
    _initSystemChrome();
    if (kDebugMode) {
      PluginManager.instance // Register plugin kits
        ..register(const WidgetInfoInspector())
        ..register(const ColorSucker())
        ..register(AlignRuler())
        // ..register(const ColorPicker())                            // New feature
        ..register(const TouchIndicator())
        ..register(Console()); // Pass in your Dio instance
      // After flutter_ume 0.3.0
      runApp(MaterialApp(
          home: const UMEWidget(child: const MyApp(), enable: true)));
    } else {
      runApp(MaterialApp(home: const MyApp()));
    }
  } catch (e, s) {
    talker.error('launch error', e, s);
    runApp(MaterialApp(
        home: Center(
      child: Text(
        '启动失败, $e\n$s',
        style: TextStyle(fontSize: 16),
      ),
    )));
  }
}

void _initAppLifecycle() {
  appLifecycle.init();
  appLifecycle.addListener(logPersistence);
  appLifecycle.addListener(ShipServiceLifecycleWatcher());
}

void _initDatabase() {
  BubblePool.instance.init(appDatabase);
}

void _initSystemChrome() {
  SystemChannels.lifecycle.setMessageHandler((msg) async {
    talker.verbose('AppLifecycle $msg ${msg}');
    // msg是个字符串，是下面的值
    // AppLifecycleState.resumed
    // AppLifecycleState.inactive
    // AppLifecycleState.paused
    // AppLifecycleState.detached

    if (msg == 'AppLifecycleState.resumed') {
      talker.verbose('App resumed');
      // iOS在省电模式下，app切入后台一段时间后ship server会挂掉。
      // 等app返回前台时检测server状态，若server dead，则重新启动
      shipService.isServerLiving().then((isServerLiving) async {
        talker.debug('isServerLiving: $isServerLiving');
        if (!isServerLiving) {
          if (await shipService.restartShipServer()) {
            DeviceDiscover.instance.startScan(await shipService.getPort());
          }
        } else {
          DeviceDiscover.instance.startScan(await shipService.getPort());
        }
      }).catchError((error, stackTrace) =>
          talker.error('isServerLiving error', error, stackTrace));
      // shipService.startShipServer();
    } else if (msg == 'AppLifecycleState.paused') {
      talker.verbose('App paused');
      DeviceDiscover.instance.stop();
    }
    return msg;
  });

  SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        // 设置为透明
        statusBarBrightness: Brightness.light,
        systemStatusBarContrastEnforced: false,
        // 在状态栏上的图标和文字颜色为深色
        statusBarIconBrightness: Brightness.dark,
        systemNavigationBarColor: Colors.transparent,
        systemNavigationBarContrastEnforced: false,
        systemNavigationBarIconBrightness: Brightness.dark),
  );
}

Future<DeviceInfoResult> _initDeviceManager() async {
  final deviceInfo = await DeviceProfileRepo.instance.initDeviceInfo();
  DeviceManager.instance.init();
  shipService.startShipServer().then((isSuccess) async {
    if (isSuccess) {
      DeviceDiscover.instance
          .start(shipService, await shipService.getPort());
    }
  });
  return deviceInfo;
}

Future<void> initWindowManager() async {
  await flixWindowsManager.init();
  flixWindowsManager.restoreWindow();
}

Future<void> initFireBase() async {
  if (Platform.isMacOS || Platform.isIOS || Platform.isAndroid) {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );

    FlutterError.onError = (FlutterErrorDetails details) async {
      if (kReleaseMode) {
        await FirebaseCrashlytics.instance.recordFlutterFatalError;
      } else {
        talker.critical(details);
      }
    };
    PlatformDispatcher.instance.onError = (error, stack) {
      if (kReleaseMode) {
        FirebaseCrashlytics.instance.recordError(error, stack,
            fatal: true, information: ['platform errors']);
      } else {
        talker.critical('platform errors', error, stack);
      }
      return true;
    };
  }
}

// linux需要前置安装其他库： https://pub.dev/packages/system_tray
Future<void> initSystemManager() async {
  if (!(Platform.isMacOS || Platform.isWindows || Platform.isLinux)) {
    return;
  }
  const String _iconPathWin = 'assets/images/tray_logo.ico';
  const String _iconPathOther = 'assets/images/tray_logo_no_color.png';
  final SystemTray systemTray = SystemTray();

  // We first init the systray menu
  await systemTray.initSystemTray(
    iconPath: Platform.isWindows ? _iconPathWin : _iconPathOther,
    isTemplate: Platform.isMacOS,
  );

  // if (Platform.isMacOS) {
  //   await systemTray.setImage(_iconPathOther, isTemplate: true);
  // }

  // create context menu
  final Menu menu = Menu();
  await menu.buildFrom([
    MenuItemLabel(label: 'Show', onClicked: (menuItem) => windowManager.show()),
    MenuItemLabel(
        label: 'Hide',
        onClicked: (menuItem) {
          if (Platform.isWindows) {
            windowManager.hide();
          } else {
            windowManager.minimize();
          }
        }),
    MenuItemLabel(
        label: 'Exit', onClicked: (menuItem) => windowManager.destroy()),
  ]);

  // set context menu
  await systemTray.setContextMenu(menu);

  // handle system tray event
  systemTray.registerSystemTrayEventHandler((eventName) {
    debugPrint("eventName: $eventName");
    if (eventName == kSystemTrayEventClick) {
      Platform.isWindows ? windowManager.show() : systemTray.popUpContextMenu();
    } else if (eventName == kSystemTrayEventRightClick) {
      Platform.isWindows ? systemTray.popUpContextMenu() : windowManager.show();
    }
  });
}

Future<void> initBootStartUp() async {
  if (!(Platform.isMacOS || Platform.isWindows || Platform.isLinux)) {
    return;
  }
  PackageInfo packageInfo = await PackageInfo.fromPlatform();
  launchAtStartup.setup(
    appName: packageInfo.appName,
    appPath: Platform.resolvedExecutable,
  );
  bool isEnabled = await launchAtStartup.isEnabled();
}

Future<void> _logAppContext(DeviceInfoResult deviceInfo) async {
  String operatingSystem = '';
  String operatingSystemVersion = '';
  final info = await PackageInfo.fromPlatform();
  try {
    operatingSystem = Platform.operatingSystem;
    operatingSystemVersion = Platform.operatingSystemVersion;
  } catch (e, s) {
    talker.error('get platform info error', e, s);
  }
  talker.info(
      'name: ${deviceInfo.alias}, Model: ${deviceInfo.deviceModel}, Platform: $operatingSystem, Version: $operatingSystemVersion, AppVersion: ${info.version}');
}

Future<void> _initNotification() async {
  await flixNotification.init();
  NotificationService.instance.init();
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
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => SettingProvider()),
        ChangeNotifierProvider<MultiCastClientProvider>(
            create: (_) => MultiCastClientProvider()),
        ChangeNotifierProvider(create: (context) => AndropContext())
      ],
      child: MaterialApp(
        title: 'Flix',
        navigatorObservers: [modalsRouteObserver],
        navigatorKey: navigatorKey,
        localizationsDelegates: <LocalizationsDelegate<dynamic>>[
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: [
          Locale.fromSubtags(
              languageCode: 'zh', scriptCode: 'Hans', countryCode: 'CN'),
        ],
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
        ).useSystemChineseFont(Brightness.light),
        // initialRoute: 'home',
        builder: FToastBuilder(),
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

class _MyHomePageState extends BaseScreenState<MyHomePage> with WindowListener {
  var selectedIndex = 0;

  // DeviceInfo? selectedDevice;
  bool isLeaved = false;
  Widget? thirdWidget;

  Center selectedDeviceTipsScreen() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SvgPicture.asset('assets/images/img_placeholder.svg'),
          const SizedBox(
            height: 16,
          ),
          Text(
            '请选择设备',
            style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.normal,
                    color: Colors.black)
                .useSystemChineseFont(),
          )
        ],
      ),
    );
  }

  // Platform messages are asynchronous, so we initialize in an async method.
  Future<void> initPlatformState() async {
    if (Platform.isAndroid || Platform.isIOS) {
      final handler = ShareHandlerPlatform.instance;
      final media = await handler.getInitialSharedMedia();
      _tryGoPickDeviceScreen(media);
      handler.sharedMediaStream.listen((SharedMedia media) {
        _tryGoPickDeviceScreen(media);
      });
      if (!mounted) return;
    }
  }

  Future<void> initWindowClose() async {
    if (Platform.isMacOS || Platform.isLinux || Platform.isWindows) {
      windowManager.setPreventClose(true);
      windowManager.addListener(this);
    }
  }

  @override
  Future<void> onWindowClose() async {
    if (Platform.isWindows) {
      windowManager.hide();
    } else {
      windowManager.minimize();
    }
  }

  void _tryGoPickDeviceScreen(SharedMedia? sharedMedia) {
    if (sharedMedia == null) {
      talker.error('shareMedia is null');
      return;
    }
    if (!mounted) {
      talker.warning('widget not unmounted');
      return;
    }

    Navigator.pushAndRemoveUntil(
            context,
            CupertinoPageRoute<DeviceInfo?>(
                builder: (context) =>
                    PickDeviceScreen(sharedMedia: sharedMedia)),
            ModalRoute.withName('/'))
        .then((deviceInfo) {
      if (deviceInfo == null) {
        talker.warning('取消分享，未选择设备');
      } else {
        setState(() {
          BadgeService.instance.clearBadgesFrom(deviceInfo.id);
          thirdWidget = ConcertScreen(
            deviceInfo: deviceInfo,
            showBackButton: true,
          );
        });
      }
    });
  }

  @override
  void initState() {
    super.initState();
    flixToast.init(navigatorKey.currentContext!);
    initPlatformState();
    initWindowClose();
    _initNotificationListener();
  }

  void _initNotificationListener() {
    flixNotification.receptionNotificationStream.stream
        .listen((receptionNotification) async {
      if (Platform.isWindows) {
        // trick: 直接使用show, 大概率无法把窗口展示在最上方
        await windowManager.setAlwaysOnTop(true);
        await windowManager.show();
        await windowManager.focus();
        // Future.delayed(Duration(seconds: 1), () async {
        await windowManager.setAlwaysOnTop(false);
        // });
      }
      final deviceModal = DeviceManager.instance.deviceList
          .find((element) => element.fingerprint == receptionNotification.from);
      if (deviceModal != null) {
        if (isOverMediumWidth(context)) {
          setSelectedIndex(0);
          BadgeService.instance.clearBadgesFrom(deviceModal.fingerprint);
          setState(() {
            thirdWidget = ConcertScreen(
              deviceInfo: deviceModal.toDeviceInfo(),
              showBackButton: false,
            );
          });
        } else {
          Navigator.push(context, CupertinoPageRoute(builder: (context) {
            return ConcertScreen(
              deviceInfo: deviceModal.toDeviceInfo(),
              showBackButton: true,
            );
          }));
        }
      } else {
        talker.error('can\'t find device by id: ${receptionNotification.from}');
      }
    });
  }

  @override
  void dispose() {
    flixNotification.receptionNotificationStream.close();
    super.dispose();
  }

  void setSelectedIndex(int index) {
    setState(() {
      selectedIndex = index;
    });
  }

  // void setSelectedDevice(DeviceInfo? deviceInfo) {
  //   setState(() {
  //     selectedDevice = deviceInfo;
  //   });
  // }

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
    if (isOverMediumWidth(context)) {
      return WideLayout();
    } else {
      return NarrowLayout();
    }
  }

  Widget NarrowLayout() {
    return Scaffold(
      backgroundColor: const Color.fromRGBO(247, 247, 247, 1),
      body: NarrowBody(),
      bottomNavigationBar: ConstrainedBox(
        constraints: BoxConstraints(
            minHeight: 70 + MediaQuery.of(context).padding.bottom),
        child: BottomNavigationBar(
          items: [
            BottomNavigationBarItem(
                icon: SvgPicture.asset(
                  width: 26,
                  height: 26,
                  'assets/images/ic_share.svg',
                  colorFilter: ColorFilter.mode(
                      getColor(0, selectedIndex), BlendMode.srcIn),
                ),
                label: '互传'),
            BottomNavigationBarItem(
                icon: SvgPicture.asset(
                  width: 26,
                  height: 26,
                  'assets/images/ic_config.svg',
                  colorFilter: ColorFilter.mode(
                      getColor(1, selectedIndex), BlendMode.srcIn),
                ),
                label: '配置'),
            BottomNavigationBarItem(
                icon: SvgPicture.asset(
                  width: 26,
                  height: 26,
                  'assets/images/ic_help.svg',
                  colorFilter: ColorFilter.mode(
                      getColor(2, selectedIndex), BlendMode.srcIn),
                ),
                label: '帮助'),
          ],
          currentIndex: selectedIndex,
          selectedItemColor: Colors.black,
          unselectedItemColor: const Color.fromRGBO(60, 60, 67, 0.3),
          selectedFontSize: 12,
          unselectedFontSize: 12,
          selectedLabelStyle:
              const TextStyle(fontWeight: FontWeight.w400, fontSize: 12)
                  .useSystemChineseFont(),
          unselectedLabelStyle:
              const TextStyle(fontWeight: FontWeight.w400, fontSize: 12)
                  .useSystemChineseFont(),
          backgroundColor: Colors.white,
          elevation: 0,
          onTap: (value) => setSelectedIndex(value),
        ),
      ),
    );
  }

  Widget NarrowBody() {
    switch (selectedIndex) {
      case 0:
        return DeviceScreen(
          onDeviceSelected: (deviceInfo, isHistory) => Navigator.push(
              context,
              CupertinoPageRoute(
                  builder: (context) => ConcertScreen(
                        deviceInfo: deviceInfo,
                        showBackButton: true,
                        playable: !isHistory,
                      ))),
        );
      case 1:
        return SettingsScreen();
      case 2:
        return HelpScreen(
          goVersionScreen: () {
            Navigator.push(context,
                CupertinoPageRoute(builder: (context) => AboutUSScreen()));
          },
        );
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
                    width: 26,
                    height: 26,
                    colorFilter: ColorFilter.mode(
                        getColor(0, selectedIndex), BlendMode.srcIn),
                  ),
                  label: Text('互传')),
              NavigationRailDestination(
                  icon: SvgPicture.asset(
                    'assets/images/ic_config.svg',
                    width: 26,
                    height: 26,
                    colorFilter: ColorFilter.mode(
                        getColor(1, selectedIndex), BlendMode.srcIn),
                  ),
                  label: Text('配置')),
              NavigationRailDestination(
                  icon: SvgPicture.asset(
                    'assets/images/ic_help.svg',
                    width: 26,
                    height: 26,
                    colorFilter: ColorFilter.mode(
                        getColor(2, selectedIndex), BlendMode.srcIn),
                  ),
                  label: Text('帮助'))
            ],
            minWidth: 60,
            labelType: NavigationRailLabelType.all,
            useIndicator: true,
            indicatorColor: Colors.white,
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
              fontWeight: FontWeight.normal,
            ).useSystemChineseFont(),
            unselectedLabelTextStyle: const TextStyle(
                    color: Color.fromRGBO(60, 60, 67, 0.3),
                    fontSize: 12,
                    fontWeight: FontWeight.normal)
                .useSystemChineseFont(),
            backgroundColor: Colors.white,
          ),
          Flexible(flex: 1, child: secondPart()),
          Expanded(
            flex: 2,
            child: thirdPart(),
          )
        ],
      ),
    );
  }

  Widget secondPart() {
    switch (selectedIndex) {
      case 0:
        return DeviceScreen(
          onDeviceSelected: (deviceInfo, isHistory) {
            BadgeService.instance.clearBadgesFrom(deviceInfo.id);
            setState(() {
              thirdWidget = ConcertScreen(
                deviceInfo: deviceInfo,
                showBackButton: false,
                playable: !isHistory,
              );
            });
          },
        );
      case 1:
        return SettingsScreen();
      case 2:
        return HelpScreen(
          goVersionScreen: () {
            setState(() {
              thirdWidget = AboutUSScreen(
                showBack: false,
              );
            });
          },
        );
      default:
        return Placeholder();
    }
  }

  Widget thirdPart() {
    // final deviceInfo = selectedDevice;

    // if (deviceInfo != null) {
    //   return ;
    // } else {
    //   return selectedDeviceTipsScreen();
    // }

    if (thirdWidget == null) {
      return selectedDeviceTipsScreen();
    } else {
      return thirdWidget!;
    }
  }
}
