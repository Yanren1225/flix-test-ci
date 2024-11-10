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
import 'package:flix/domain/ship_server/ship_service_lifecycle_watcher.dart';
import 'package:flix/domain/ship_server/ship_service_proxy.dart';
import 'package:flix/domain/uri_router.dart';
import 'package:flix/domain/window/flix_window_manager.dart';
import 'package:flix/l10n/l10n.dart';
import 'package:flix/l10n/lang_config.dart';
import 'package:flix/network/discover/discover_manager.dart';
import 'package:flix/network/multicast_client_provider.dart';
import 'package:flix/presentation/screens/intro_screen.dart';
import 'package:flix/presentation/screens/main_screen.dart';
import 'package:flix/presentation/widgets/hotkeyprovider.dart';
import 'package:flix/setting/setting_provider.dart';
import 'package:flix/theme/theme.dart';
import 'package:flix/theme/theme_extensions.dart';
import 'package:flix/utils/device_info_helper.dart';
import 'package:flix/utils/exit.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_displaymode/flutter_displaymode.dart';
import 'package:flutter_foreground_task/flutter_foreground_task.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:hotkey_manager/hotkey_manager.dart';
import 'package:launch_at_startup/launch_at_startup.dart';
import 'package:modals/modals.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tray_manager/tray_manager.dart';
import 'package:window_manager/window_manager.dart';

import 'domain/foreground_service/flix_foreground_service.dart';
import 'firebase_options.dart';

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
    // For hot reload, `unregisterAll()` needs to be called.
    await hotKeyManager.unregisterAll();
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
        Navigator.pushReplacement(
          navigatorKey.currentContext!,
          MaterialPageRoute(builder: (context) => IntroPage()),
        );
      });
    } else {
      Future.delayed(Duration.zero, () {
        Navigator.pushReplacementNamed(
          navigatorKey.currentContext!,
          "/main",
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
          ChangeNotifierProvider(create: (context) => AndropContext()),
          ChangeNotifierProvider(create: (_) => BackProvider()),
          ChangeNotifierProvider(create: (_) => HotKeyProvider()),
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
                  localizationsDelegates: const <LocalizationsDelegate<
                      dynamic>>[
                    S.delegate,
                    GlobalMaterialLocalizations.delegate,
                    GlobalWidgetsLocalizations.delegate,
                    GlobalCupertinoLocalizations.delegate,
                  ],
                  supportedLocales: S.delegate.supportedLocales,
                  theme:
                      (userDarkMode ? flixDark(context) : flixLight(context)),
                  locale: LangConfig.instance.current,
                  // initialRoute: 'home',
                  routes: {
                    "/main": (context) => const MainScreen()
                  },
                  builder: FToastBuilder(),
                  home: Container(
                    color: Theme.of(context)
                        .flixColors
                        .background
                        .secondary,
                    child: Center(
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: SizedBox(
                          width: 110,
                          height: 110,
                          child: Image.asset(
                            'assets/images/logo.webp',
                            fit: BoxFit.contain,
                          ),
                        ),
                      ),
                    ),
                  ));
            }));
  }
}
