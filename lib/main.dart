import 'dart:async';
import 'dart:io';
import 'dart:ui';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flix/domain/analytics/flix_analytics.dart';
import 'package:flix/domain/androp_context.dart';
import 'package:flix/domain/bubble_pool.dart';
import 'package:flix/domain/clipboard/flix_clipboard_manager.dart';
import 'package:flix/domain/database/database.dart';
import 'package:flix/domain/device/device_discover.dart';
import 'package:flix/domain/device/device_manager.dart';
import 'package:flix/domain/device/device_profile_repo.dart';
import 'package:flix/domain/hotspot/ap_router_handler.dart';
import 'package:flix/domain/hotspot/hotspot_manager.dart';
import 'package:flix/domain/lifecycle/app_lifecycle.dart';
import 'package:flix/domain/lifecycle/platform_state.dart';
import 'package:flix/domain/log/flix_log.dart';
import 'package:flix/domain/log/persistence/log_persistence_proxy.dart';
import 'package:flix/domain/notification/flix_notification.dart';
import 'package:flix/domain/notification/notification_service.dart';
import 'package:flix/domain/paircode/pair_router_handler.dart';
import 'package:flix/domain/settings/settings_repo.dart';
import 'package:flix/domain/ship_server/heart_manager.dart';
import 'package:flix/domain/ship_server/ship_service_lifecycle_watcher.dart';
import 'package:flix/domain/ship_server/ship_service_proxy.dart';
import 'package:flix/domain/uri_router.dart';
import 'package:flix/domain/version/version_checker.dart';
import 'package:flix/domain/window/flix_window_manager.dart';
import 'package:flix/l10n/l10n.dart';
import 'package:flix/l10n/lang_config.dart';
import 'package:flix/model/device_info.dart';
import 'package:flix/network/discover/discover_manager.dart';
import 'package:flix/network/multicast_client_provider.dart';
import 'package:flix/presentation/screens/concert/concert_screen.dart';
import 'package:flix/presentation/screens/devices_screen.dart';
import 'package:flix/presentation/screens/helps/about_us.dart';
import 'package:flix/presentation/screens/helps/donate_us.dart';
import 'package:flix/presentation/screens/helps/recent_screen.dart';
import 'package:flix/presentation/screens/helps/qa.dart';
import 'package:flix/presentation/screens/intro_screen.dart';
import 'package:flix/presentation/screens/paircode/add_device_screen.dart';
import 'package:flix/presentation/screens/paircode/pair_code_screen.dart';
import 'package:flix/presentation/screens/pick_device_screen.dart';
import 'package:flix/presentation/screens/settings/cross_device_clipboard_screen.dart';
import 'package:flix/presentation/screens/settings/settings_screen.dart';
import 'package:flix/presentation/widgets/flix_toast.dart';
import 'package:flix/setting/setting_provider.dart';
import 'package:flix/theme/theme.dart';
import 'package:flix/theme/theme_extensions.dart';
import 'package:flix/theme/theme_util.dart';
import 'package:flix/utils/device/device_utils.dart';
import 'package:flix/utils/device_info_helper.dart';
import 'package:flix/utils/exit.dart';
import 'package:flix/utils/iterable_extension.dart';
import 'package:flix/utils/meida/media_utils.dart';
import 'package:flix/utils/text/text_extension.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_displaymode/flutter_displaymode.dart';
import 'package:flutter_foreground_task/flutter_foreground_task.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_svg/svg.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:launch_at_startup/launch_at_startup.dart';
import 'package:modals/modals.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:provider/provider.dart';
import 'package:share_handler/share_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tray_manager/tray_manager.dart';
import 'package:window_manager/window_manager.dart';

import 'domain/foreground_service/flix_foreground_service.dart';
import 'domain/notification/badge_service.dart';
import 'firebase_options.dart';
import 'presentation/screens/base_screen.dart';

// final demoSplitViewKey = GlobalKey<NavigatorState>();
// final _leftKey = GlobalKey();

GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

bool needExitApp = false;

String kAppTrayModeArg = '--apptray';

bool isFirstRun = true;

Future<void> main(List<String> arguments) async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await logPersistence.init();
    initLog();
    await _initHighRefreshRate();
    await initFireBase();
    _initForegroundTask();
    await initWindowManager(arguments.contains(kAppTrayModeArg));
    await initBootStartUp();
    await _initNotification();
    await initSystemManager();
    _initDatabase();
    final deviceInfo = await _initDeviceManager();
    initClipboard();
    _logAppContext(deviceInfo);
    _initAppLifecycle();
    _initSystemChrome();
    _initUriNavigator();
    runApp(const WithForegroundTask(child: MyApp()));
    SharedPreferences prefs = await SharedPreferences.getInstance();
    isFirstRun = prefs.getBool('isFirstRun') ?? true;
  } catch (e, s) {
    talker.error('launch error', e, s);

    runApp(MaterialApp(
        home: Center(
      child: Text(
        '启动失败, $e\n$s',
        style: const TextStyle(fontSize: 16),
      ),
    )));
  }
}

void _initUriNavigator() {
  final apRouterHandler = ApRouterHandler();
  final pairRouterHandler = PairRouterHandler();
  uriRouter.registerHandler(apRouterHandler.host, apRouterHandler);
  uriRouter.registerHandler(pairRouterHandler.host, pairRouterHandler);
}

void initClipboard() {
  DeviceManager.instance.addPairDeviceChangeListener((pairDevices) {
    if (pairDevices.isNotEmpty) {
      if (FlixClipboardManager.instance.isAlive) {
        return;
      }
      FlixClipboardManager.instance.startWatcher();
    } else {
      FlixClipboardManager.instance.stopWatcher();
    }
  });
}

void _initForegroundTask() {
  if (Platform.isAndroid || Platform.isIOS) {
    flixForegroundService.init();
    flixForegroundService.start();
  }
}

Future<void> _initHighRefreshRate() async {
  if (Platform.isAndroid) {
    await FlutterDisplayMode.setHighRefreshRate();
  }
}

void _initAppLifecycle() {
  appLifecycle.addListener(logPersistence);
  if (Platform.isAndroid || Platform.isIOS) {
    appLifecycle.addListener(flixForegroundService);
  }
  final shipServiceLifecycleWatcher = ShipServiceLifecycleWatcher();
  appLifecycle.addListener(shipServiceLifecycleWatcher);
  platformStateDispatcher.addListener(shipServiceLifecycleWatcher);
  appLifecycle.addListener(hotspotManager);
  appLifecycle.addListener(FlixClipboardManager.instance);
}

void _initDatabase() {
  BubblePool.instance.init(appDatabase);
}

void _initSystemChrome() {
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
      final port = await shipService.getPort();
      DiscoverManager.instance.startDiscover(port);
      // HeartManager.instance.startHeartTimer();
    }
  });
  return deviceInfo;
}

Future<void> initWindowManager(bool hideOnStartup) async {
  await flixWindowsManager.init();
  if (hideOnStartup && Platform.isLinux) {
    // FIXME: https://github.com/leanflutter/window_manager/issues/460 的临时解决方案
    await windowManager.hide();
  }
  if (!hideOnStartup) {
    flixWindowsManager.restoreWindow();
  }
}

Future<void> initFireBase() async {
  if (Platform.isMacOS || Platform.isIOS || Platform.isAndroid) {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );

    FlutterError.onError = (FlutterErrorDetails details) async {
      if (kReleaseMode) {
        await FirebaseCrashlytics.instance.recordFlutterError(details);
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

    flixAnalytics.logAppOpen();
  }
}

// linux需要前置安装其他库： https://pub.dev/packages/tray_manager
//TODO: 国际化
Future<void> initSystemManager() async {
  if (!(Platform.isMacOS || Platform.isWindows || Platform.isLinux)) {
    return;
  }
  const String iconPathWin = 'assets/images/tray_logo.ico';
  const String iconPathOther = 'assets/images/tray_logo_no_color.png';

  // We first init the systray menu
  await trayManager.setIcon(
    Platform.isWindows ? iconPathWin : iconPathOther,
    isTemplate: Platform.isMacOS,
  );

  // create context menu
  final Menu menu = Menu(items: [
    MenuItem(label: '显示', onClick: (menuItem) => windowManager.show()),
    MenuItem(
        label: '隐藏',
        onClick: (menuItem) {
          if (Platform.isWindows) {
            windowManager.hide();
          } else {
            windowManager.minimize();
          }
        }),
    MenuItem(label: '退出', onClick: (menuItem) => doExit()),
  ]);

  // set context menu
  await trayManager.setContextMenu(menu);

  // handle system tray event
  trayManager.addListener(ShowUpTrayListener());
}

/// 支持一个鼠标键显示菜单、另一个鼠标键显示窗口
class ShowUpTrayListener with TrayListener {
  @override
  void onTrayIconMouseDown() {
    if (Platform.isWindows) {
      windowManager.show();
    } else {
      trayManager.popUpContextMenu();
    }
  }

  @override
  void onTrayIconRightMouseDown() {
    if (Platform.isWindows) {
      trayManager.popUpContextMenu();
    } else {
      windowManager.show();
    }
  }
}

Future<void> initBootStartUp() async {
  if (!(Platform.isMacOS || Platform.isWindows || Platform.isLinux)) {
    return;
  }
  PackageInfo packageInfo = await PackageInfo.fromPlatform();
  launchAtStartup.setup(
    appName: packageInfo.appName,
    appPath: Platform.resolvedExecutable,
    args: [kAppTrayModeArg],
  );
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

class MyAppState extends State<MyApp> with WidgetsBindingObserver {
  // This widget is the root of your application.

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    if (isFirstRun) {
      Future.delayed(Duration.zero, () {
        Navigator.push(
          navigatorKey.currentContext!,
          MaterialPageRoute(builder: (context) => intropage()),
        );
      });
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    appLifecycle.dispatchLifecycleEvent(state);
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => SettingProvider()),
          ChangeNotifierProvider<MultiCastClientProvider>(
              create: (_) => MultiCastClientProvider()),
          ChangeNotifierProvider(create: (context) => AndropContext())
        ],
        child: StreamBuilder<String>(
            initialData: SettingsRepo.instance.darkModeTag,
            stream: SettingsRepo.instance.darkModeTagStream.stream,
            builder: (context, darkModeTag) {
              bool userDarkMode = darkModeTag.data == "follow_system"
                  ? MediaQuery.of(context).platformBrightness == Brightness.dark
                  : darkModeTag.data == "always_on";

              return MaterialApp(
                onGenerateTitle: (context) => S.of(context).app_name,
                navigatorObservers: [modalsRouteObserver],
                navigatorKey: navigatorKey,
                localizationsDelegates: const <LocalizationsDelegate<dynamic>>[
                  S.delegate,
                  GlobalMaterialLocalizations.delegate,
                  GlobalWidgetsLocalizations.delegate,
                  GlobalCupertinoLocalizations.delegate,
                ],
                supportedLocales: S.delegate.supportedLocales,
                theme: (userDarkMode ? flixDark(context) : flixLight(context)),
                locale: LangConfig.instance.current,
                // initialRoute: 'home',
                builder: FToastBuilder(),
                home: Stack(
                  children: [
                    const MyHomePage(title: 'Flix'),
                    if (Platform.isMacOS ||
                        Platform.isLinux ||
                        Platform.isWindows)
                      Positioned(
                        top: 0,
                        left: 0,
                        right: 0,
                        child: GestureDetector(
                          onPanStart: (details) {
                            windowManager.startDragging();
                          },
                          onDoubleTap: () async {
                            bool isMaximized =
                                await windowManager.isMaximized();
                            if (isMaximized) {
                              windowManager.restore();
                            } else {
                              windowManager.maximize();
                            }
                          },
                          child: Container(
                            height: 30.0,
                            color: const Color.fromARGB(0, 33, 149, 243),
                            child: AppBar(
                              title: const Text(''),
                              actions: [
                                //  Material(
                                //   color: Colors.transparent,
                                //   child: InkWell(
                                //     customBorder: RoundedRectangleBorder(
                                //       borderRadius: BorderRadius.circular(0),
                                //     ),
                                //     onTap: () async {
                                //       bool isToped = await windowManager.isAlwaysOnTop();
                                //       if (isToped) {
                                //         windowManager.setAlwaysOnTop(false);
                                //       } else {
                                //         windowManager.setAlwaysOnTop(true);
                                //      }
                                //    },
                                //     child: const Padding(
                                //       padding: EdgeInsets.all(8.0),
                                //       child: Icon(
                                //          Icons.push_pin_outlined,
                                //       size: 14.0,
                                //       ),
                                //       ),
                                //     ),
                                //    ),
                                Material(
                                  color: Colors.transparent,
                                  child: InkWell(
                                    customBorder: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(0),
                                    ),
                                    onTap: () {
                                      windowManager.minimize();
                                    },
                                    child: const Padding(
                                      padding: EdgeInsets.all(8.0),
                                      child: Icon(
                                        Icons.horizontal_rule,
                                        size: 14.0,
                                      ),
                                    ),
                                  ),
                                ),
                                Material(
                                  color: Colors.transparent,
                                  child: InkWell(
                                    customBorder: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(0),
                                    ),
                                    onTap: () async {
                                      bool isMaximized =
                                          await windowManager.isMaximized();
                                      if (isMaximized) {
                                        windowManager.restore();
                                      } else {
                                        windowManager.maximize();
                                      }
                                    },
                                    child: const Padding(
                                      padding: EdgeInsets.all(8.0),
                                      child: Icon(
                                        Icons.crop_square,
                                        size: 14.0,
                                      ),
                                    ),
                                  ),
                                ),
                                Material(
                                  color: Colors.transparent,
                                  child: InkWell(
                                    customBorder: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(0),
                                    ),
                                    hoverColor:
                                        const Color.fromARGB(255, 208, 24, 11)
                                            .withOpacity(0.8),
                                    onTap: () {
                                      windowManager.hide();
                                    },
                                    child: const Padding(
                                      padding: EdgeInsets.all(8.0),
                                      child: Icon(
                                        Icons.close,
                                        size: 15.0,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                              backgroundColor: Colors.transparent,
                              elevation: 0,
                            ),
                          ),
                        ),
                      )
                  ],
                ),
              );
            }));
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

class _MyHomePageState extends BaseScreenState<MyHomePage>
    with WindowListener, WidgetsBindingObserver {
  var selectedIndex = 0;

  // DeviceInfo? selectedDevice;
  bool isLeaved = false;
  Widget? thirdWidget;

  Center selectedDeviceTipsScreen() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Image.asset(
            isDarkMode(context)
                ? 'assets/images/image_placeholder_dark.png'
                : 'assets/images/image_placeholder_light.png',
            fit: BoxFit.contain,
            width: 170,
          ),
          const SizedBox(
            height: 16,
          ),
          Text(
            S.of(context).homepage_select_device,
            style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.normal,
                    color: Theme.of(context).flixColors.text.secondary)
                .fix(),
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
    WidgetsBinding.instance.addObserver(this);
    flixToast.init(navigatorKey.currentContext!);
    initPlatformState();
    initWindowClose();
    _initNotificationListener();
    VersionChecker.checkNewVersion(context);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    if (state == AppLifecycleState.resumed) {
      VersionChecker.checkNewVersion(context);
    }
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
    WidgetsBinding.instance.removeObserver(this);
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

  Color getColor(BuildContext context, int index, int selectedIndex) {
    return index == selectedIndex
        ? Theme.of(context).flixColors.text.primary
        : Theme.of(context).flixColors.text.tertiary;
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
      backgroundColor: Theme.of(context).flixColors.background.secondary,
      body: NarrowBody(),
      bottomNavigationBar: ConstrainedBox(
        constraints: BoxConstraints(
            minHeight: 70 + MediaQuery.of(context).padding.bottom),
        child: ClipRect(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 20.0, sigmaY: 20.0),
            child: Container(
              color: Theme.of(context).flixColors.background.primary.withOpacity(0.9),
              child: BottomNavigationBar(
                items: [
                  BottomNavigationBarItem(
                    icon: SvgPicture.asset(
                      width: 26,
                      height: 26,
                      'assets/images/ic_share.svg',
                      colorFilter: ColorFilter.mode(
                        selectedIndex == 0
                            ? Theme.of(context).flixColors.text.primary
                            : (Theme.of(context).brightness == Brightness.dark
                                ? const Color.fromRGBO(235, 235, 245, 0.3)
                                : const Color.fromRGBO(60, 60, 67, 0.3)),
                        BlendMode.srcIn,
                      ),
                    ),
                    label: '',
                  ),
                  BottomNavigationBarItem(
                      icon: SvgPicture.asset(
                        width: 26,
                        height: 26,
                        'assets/images/search.svg',
                        colorFilter: ColorFilter.mode(
                          selectedIndex == 1
                              ? Theme.of(context).flixColors.text.primary
                              : (Theme.of(context).brightness == Brightness.dark
                                  ? const Color.fromRGBO(235, 235, 245, 0.3)
                                  : const Color.fromRGBO(60, 60, 67, 0.3)),
                          BlendMode.srcIn,
                        ),
                      ),
                      label: ''),
                  BottomNavigationBarItem(
                      icon: SvgPicture.asset(
                        width: 26,
                        height: 26,
                        'assets/images/setting.svg',
                        colorFilter: ColorFilter.mode(
                          selectedIndex == 2
                              ? Theme.of(context).flixColors.text.primary
                              : (Theme.of(context).brightness == Brightness.dark
                                  ? const Color.fromRGBO(235, 235, 245, 0.3)
                                  : const Color.fromRGBO(60, 60, 67, 0.3)),
                          BlendMode.srcIn,
                        ),
                      ),
                      label: ''),
                ],
                currentIndex: selectedIndex,
                selectedItemColor: Theme.of(context).flixColors.text.primary,
                unselectedItemColor: Theme.of(context).flixColors.text.tertiary,
                selectedFontSize: 12,
                unselectedFontSize: 12,
                showSelectedLabels: false,
                showUnselectedLabels: false,
                selectedLabelStyle:
                    const TextStyle(fontWeight: FontWeight.w400, fontSize: 12)
                        .fix(),
                unselectedLabelStyle:
                    const TextStyle(fontWeight: FontWeight.w400, fontSize: 12)
                        .fix(),
                backgroundColor: Colors.transparent,
                elevation: 0,
                onTap: (value) => setSelectedIndex(value),
              ),
            ),
          ),
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
                        playable: true,
                      ))),
          onViewConnectInfo: () => Navigator.push(context,
              CupertinoPageRoute(builder: (context) => const PairCodeScreen())),
          onGoManualAdd: () => Navigator.push(
              context,
              CupertinoPageRoute(
                  builder: (context) => const AddDeviceScreen())),
        );
      case 1:
         return recentScreen(
         
          goDonateCallback: () {
            Navigator.push(
                context,
                CupertinoPageRoute(
                    builder: (context) => DonateUSScreen(
                          showBack: true,
                        )));
          }, goQACallback: () { Navigator.push(
                context,
                CupertinoPageRoute(
                    builder: (context) => QAScreen(
                          showBack: true,
                        ))); },
        );
      case 2:
       return SettingsScreen(
         goVersionScreen: () {
            Navigator.push(
                context,
                CupertinoPageRoute(
                    builder: (context) => const AboutUSScreen(
                          showBack: true,
                        )));
          },
          crossDeviceCallback: () {
            Navigator.push(
                context,
                CupertinoPageRoute(
                    builder: (context) => CrossDeviceClipboardScreen()));
          },
          showConnectionInfoCallback: () {
            Navigator.push(
                context,
                CupertinoPageRoute(
                    builder: (context) => const PairCodeScreen()));
          },
          goManualAddCallback: () {
            Navigator.push(
                context,
                CupertinoPageRoute(
                    builder: (context) => const AddDeviceScreen()));
          },
           goDonateCallback: () {
            Navigator.push(
                context,
                CupertinoPageRoute(
                    builder: (context) => DonateUSScreen(
                          showBack: true,
                        )));
          }, goQACallback: () {  Navigator.push(
                context,
                CupertinoPageRoute(
                    builder: (context) => QAScreen(
                          showBack: true,
                        ))); },
        );
       
      default:
        return const Placeholder();
    }
  }

  Widget WideLayout() {
    return Scaffold(
      backgroundColor: Theme.of(context).flixColors.background.secondary,
      body: Row(
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 5),
            child: SizedBox(
              width: 60,
              child: NavigationRail(
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
                            getColor(context, 0, selectedIndex),
                            BlendMode.srcIn),
                      ),
                      label: const Text('')),
                  NavigationRailDestination(
                      icon: SvgPicture.asset(
                        'assets/images/search.svg',
                        width: 26,
                        height: 26,
                        colorFilter: ColorFilter.mode(
                            getColor(context, 1, selectedIndex),
                            BlendMode.srcIn),
                      ),
                      label: const Text('')),
                  NavigationRailDestination(
                      icon: SvgPicture.asset(
                        'assets/images/setting.svg',
                        width: 26,
                        height: 26,
                        colorFilter: ColorFilter.mode(
                            getColor(context, 2, selectedIndex),
                            BlendMode.srcIn),
                      ),
                      label: const Text(''))
                ],
                labelType: NavigationRailLabelType.all,
                useIndicator: true,
                indicatorColor:
                    Theme.of(context).flixColors.background.secondary,
                groupAlignment: 0.0,
                extended: false,
                elevation: null,
                selectedIndex: selectedIndex,
                selectedIconTheme: IconThemeData(
                    size: 26, color: Theme.of(context).flixColors.text.primary),
                unselectedIconTheme: IconThemeData(
                    size: 26,
                    color: Theme.of(context).flixColors.text.tertiary),
                selectedLabelTextStyle: TextStyle(
                  color: Theme.of(context).flixColors.text.primary,
                  fontSize: 12,
                  fontWeight: FontWeight.normal,
                ).fix(),
                unselectedLabelTextStyle: TextStyle(
                        color: Theme.of(context).flixColors.text.tertiary,
                        fontSize: 12,
                        fontWeight: FontWeight.normal)
                    .fix(),
                backgroundColor:
                    Theme.of(context).flixColors.background.secondary,
              ),
            ),
          ),
          Expanded(flex: 2, child: secondPart()),
          Expanded(
            flex: 3,
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
          onViewConnectInfo: () {
            setState(() {
              thirdWidget = const PairCodeScreen();
            });
          },
          onGoManualAdd: () {
            setState(() {
              thirdWidget = const AddDeviceScreen();
            });
          },
        );
      case 1:
        return recentScreen(
          
          goDonateCallback: () {
            setState(() {
              thirdWidget = DonateUSScreen(
                showBack: false,
              );
            });
          },
          goQACallback: () {
            setState(() {
              thirdWidget = QAScreen(
                showBack: false,
              );
            });
          },
        );
      case 2:
       return SettingsScreen(crossDeviceCallback: () {
          setState(() {
            thirdWidget = CrossDeviceClipboardScreen();
          });
        }, goVersionScreen: () {
            setState(() {
              thirdWidget = const AboutUSScreen(
                showBack: false,
              );
            });
          },
          showConnectionInfoCallback: () {
          setState(() {
            thirdWidget = const PairCodeScreen();
          });
        }, goManualAddCallback: () {
          setState(() {
            thirdWidget = const AddDeviceScreen();
          });
        }, goDonateCallback: () {
            setState(() {
              thirdWidget = DonateUSScreen(
                showBack: false,
              );
            });
          }, goQACallback: () {setState(() {
              thirdWidget = QAScreen(
                showBack: false,
              );
            });  },);
       
      default:
        return const Placeholder();
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
