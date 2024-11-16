import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:ui';

import 'package:flix/domain/androp_context.dart';
import 'package:flix/domain/device/device_manager.dart';
import 'package:flix/domain/log/flix_log.dart';
import 'package:flix/domain/notification/badge_service.dart';
import 'package:flix/domain/notification/flix_notification.dart';
import 'package:flix/domain/version/version_checker.dart';
import 'package:flix/l10n/l10n.dart';
import 'package:flix/main.dart';
import 'package:flix/model/device_info.dart';
import 'package:flix/network/multicast_client_provider.dart';
import 'package:flix/presentation/screens/account/login.dart';
import 'package:flix/presentation/screens/account/vip.dart';
import 'package:flix/presentation/screens/base_screen.dart';
import 'package:flix/presentation/screens/cloud/home.dart';
import 'package:flix/presentation/screens/concert/concert_screen.dart';
import 'package:flix/presentation/screens/devices_screen.dart';
import 'package:flix/presentation/screens/helps/about_us.dart';
import 'package:flix/presentation/screens/helps/donate_us.dart';
import 'package:flix/presentation/screens/helps/qa.dart';
import 'package:flix/presentation/screens/helps/recent_screen.dart';
import 'package:flix/presentation/screens/paircode/add_device_screen.dart';
import 'package:flix/presentation/screens/paircode/pair_code_screen.dart';
import 'package:flix/presentation/screens/pick_device_screen.dart';
import 'package:flix/presentation/screens/settings/agreement.dart';
import 'package:flix/presentation/screens/settings/cross_device_clipboard_screen.dart';
import 'package:flix/presentation/screens/settings/dev/client_debug_page.dart';
import 'package:flix/presentation/screens/settings/function.dart';
import 'package:flix/presentation/screens/settings/general.dart';
import 'package:flix/presentation/screens/settings/hotkey.dart';
import 'package:flix/presentation/screens/settings/pravicy.dart';
import 'package:flix/presentation/screens/settings/settings_screen.dart';
import 'package:flix/presentation/screens/webflix.dart';
import 'package:flix/presentation/widgets/flix_toast.dart';
import 'package:flix/presentation/widgets/flixtitlebar.dart';
import 'package:flix/presentation/widgets/hotkeyprovider.dart';
import 'package:flix/presentation/widgets/settings/automatic_receive.dart';
import 'package:flix/setting/setting_provider.dart';
import 'package:flix/theme/theme_extensions.dart';
import 'package:flix/theme/theme_util.dart';
import 'package:flix/utils/device/device_utils.dart';
import 'package:flix/utils/iterable_extension.dart';
import 'package:flix/utils/meida/media_utils.dart';
import 'package:flix/utils/text/text_extension.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:hotkey_manager/hotkey_manager.dart';
import 'package:provider/provider.dart';
import 'package:share_handler/share_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:window_manager/window_manager.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({
    super.key,
  });

  @override
  State<StatefulWidget> createState() {
    return MainScreenState();
  }
}

class MainScreenState extends State<MainScreen> {
  HotKey? _registeredHotKey;
  bool isInitial = false;
  @override
  void initState() {
    super.initState();
    if (Platform.isWindows || Platform.isMacOS || Platform.isLinux) {
      _initHotKey();
    }
    isInitial = false;
    startInit();
    Provider.of<HotKeyProvider>(context, listen: false)
        .addListener(_onHotKeyUpdated);
  }

  Future<void> _initHotKey() async {
    final prefs = await SharedPreferences.getInstance();
    final hotKeyProvider = Provider.of<HotKeyProvider>(context, listen: false);

    final hotKeyString = prefs.getString('hotkey');
    if (hotKeyString != null) {
      final hotKeyMap = jsonDecode(hotKeyString) as Map<String, dynamic>;
      hotKeyProvider.updateHotKey(HotKey.fromJson(hotKeyMap));
    }
    _registerHotKey(hotKeyProvider.hotKey);
  }

  Future<void> _registerHotKey(HotKey hotKey) async {
    if (_registeredHotKey != null) {
      await hotKeyManager.unregister(_registeredHotKey!);
    }

    await hotKeyManager.register(
      hotKey,
      keyDownHandler: (hotKey) async {
        if (await windowManager.isVisible()) {
          await windowManager.hide();
        } else {
          await windowManager.show();
        }
      },
    );
    _registeredHotKey = hotKey;
  }

  void _onHotKeyUpdated() {
    final hotKeyProvider = Provider.of<HotKeyProvider>(context, listen: false);
    _registerHotKey(hotKeyProvider.hotKey);
  }

  @override
  void dispose() {
    hotKeyManager.unregister(_registeredHotKey!);
    Provider.of<HotKeyProvider>(context, listen: false)
        .removeListener(_onHotKeyUpdated);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if(!isInitial){
      return const CircularProgressIndicator();
    }
    return buildStack();
  }

  Stack buildStack() {
    return Stack(
    children: [
      MyHomePage(
        key: MyHomePage.homePageKey,
        title: 'Flix',
      ),
      if (Platform.isMacOS || Platform.isLinux || Platform.isWindows)
        const FlixTitleBar(),
    ],
  );
  }

  Future<void> startInit() async {
    await initAllConfig();
    setState(() {
      isInitial = true;
    });
  }
}

class BackProvider with ChangeNotifier {
  void backMethod() {
    final homePageState = MyHomePage.homePageKey.currentState;
    if (homePageState != null) {
      homePageState.clearThirdWidget();
    } else {}
  }
}

class MyHomePage extends StatefulWidget {
  static final GlobalKey<_MyHomePageState> homePageKey = GlobalKey();

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

  void clearThirdWidget() {
    setState(() {
      thirdWidget = null;
    });
  }

  double _leftWidth = 365.0;
  final double _minLeftWidth = 300.0;
  final double _maxLeftWidth = 500.0;
  bool _isTitleBarHidden = true;

  Center selectedDeviceTipsScreen() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (selectedIndex == 0) ...[
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
            ),
          ],
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
            ModalRoute.withName('/main'))
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
    if (Platform.isWindows || Platform.isMacOS || Platform.isLinux) {
      windowManager.addListener(this);
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    if (state == AppLifecycleState.resumed) {
      VersionChecker.checkNewVersion(context);
    }
  }

  @override
  void onWindowEvent(String eventName) async {
    if (eventName == 'focus' || eventName == 'blur') {
      // If the title bar should be hidden but might be visible, re-hide it
        await windowManager.setTitleBarStyle(TitleBarStyle.hidden);  
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
    if (Platform.isWindows || Platform.isMacOS || Platform.isLinux) {
      windowManager.removeListener(this);
    }
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
              color: Theme.of(context)
                  .flixColors
                  .background
                  .primary
                  .withOpacity(0.9),
              child: BottomNavigationBar(
                items: [
                  BottomNavigationBarItem(
                    icon: SvgPicture.asset(
                      width: 26,
                      height: 26,
                      selectedIndex == 0
                          ? 'assets/images/ic_share.svg'
                          : 'assets/images/navitem1.svg',
                      colorFilter: ColorFilter.mode(
                        selectedIndex == 0
                            ? Theme.of(context).flixColors.text.primary
                            : Theme.of(context).flixColors.text.secondary,
                        BlendMode.srcIn,
                      ),
                    ),
                    label: '',
                  ),
                  BottomNavigationBarItem(
                    icon: SvgPicture.asset(
                      width: 26,
                      height: 26,
                      selectedIndex == 1
                          ? 'assets/images/search.svg'
                          : 'assets/images/navitem2.svg',
                      colorFilter: ColorFilter.mode(
                        selectedIndex == 1
                            ? Theme.of(context).flixColors.text.primary
                            : Theme.of(context).flixColors.text.secondary,
                        BlendMode.srcIn,
                      ),
                    ),
                    label: '',
                  ),
                  BottomNavigationBarItem(
                    icon: SvgPicture.asset(
                      width: 26,
                      height: 26,
                      selectedIndex == 2
                          ? 'assets/images/setting.svg'
                          : 'assets/images/navitem3.svg',
                      colorFilter: ColorFilter.mode(
                        selectedIndex == 2
                            ? Theme.of(context).flixColors.text.primary
                            : Theme.of(context).flixColors.text.secondary,
                        BlendMode.srcIn,
                      ),
                    ),
                    label: '',
                  ),
                ],
                currentIndex: selectedIndex,
                selectedItemColor: Theme.of(context).flixColors.text.primary,
                unselectedItemColor:
                    Theme.of(context).flixColors.text.secondary,
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
                        playable: !isHistory,
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
          },
          goQACallback: () {
            Navigator.push(
                context,
                CupertinoPageRoute(
                    builder: (context) => QAScreen(
                          showBack: true,
                        )));
          },
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
          },
          goQACallback: () {
            Navigator.push(
                context,
                CupertinoPageRoute(
                    builder: (context) => QAScreen(
                          showBack: true,
                        )));
          },
          goGeneralCallback: () {
            Navigator.push(
                context,
                CupertinoPageRoute(
                    builder: (context) => GeneralScreen(
                          showBack: true,
                        )));
          },
          goSettingFunctionCallback: () {
            Navigator.push(
                context,
                CupertinoPageRoute(
                    builder: (context) => SettingFunctionScreen(
                          showBack: true,
                          crossDeviceCallback: () {
                            Navigator.push(
                                context,
                                CupertinoPageRoute(
                                    builder: (context) =>
                                        CrossDeviceClipboardScreen()));
                          },
                        )));
          },
          goAutomaticReceiveCallback: () {
            Navigator.push(
                context,
                CupertinoPageRoute(
                    builder: (context) => AutomaticReceivenScreen(
                          showBack: true,
                        )));
          },
          goSettingPravicyScreen: () {
            Navigator.push(
                context,
                CupertinoPageRoute(
                    builder: (context) => const SettingPravicyScreen(
                          showBack: true,
                        )));
          },
          goSettingAgreementScreen: () {
            Navigator.push(
                context,
                CupertinoPageRoute(
                    builder: (context) => const SettingAgreementScreen(
                          showBack: true,
                        )));
          },
          goLoginPage: () {
            Navigator.push(
                context,
                CupertinoPageRoute(
                    builder: (context) => LoginPage(
                          showBack: true,
                          goPayScreen: () {
                            Navigator.push(
                                context,
                                CupertinoPageRoute(
                                    builder: (context) => PayScreen(
                                        //  showBack: true,
                                        )));
                          },
                        )));
          },
          goCloudScreenPage: () {
            Navigator.push(
                context,
                CupertinoPageRoute(
                    builder: (context) => CloudScreenPage(
                        // showBack: true,
                        )));
          },
          goPayScreen: () {
            Navigator.push(
                context,
                CupertinoPageRoute(
                    builder: (context) => PayScreen(
                        //  showBack: true,
                        )));
          },
          goHotkeyScreen: () {
            Navigator.push(
                context,
                CupertinoPageRoute(
                    builder: (context) => HotkeyScreen(
                          showBack: true,
                        )));
          },
          goClientDebugScreen: () {
            Navigator.push(
                context,
                CupertinoPageRoute(
                    builder: (context) => const ClientInfoPage()));
          }, goFileUploadServer: () { 

              Navigator.push(
                context,
                CupertinoPageRoute(
                    builder: (context) => FileUploadServer()));
           },
        );

      default:
        return const Placeholder();
    }
  }

  Widget WideLayout() {
    return Scaffold(
      backgroundColor: Theme.of(context).flixColors.background.secondary,
      body: Stack(
        children: [
          Row(
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 24, right: 9),
                child: SizedBox(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _buildNavItem(
                        index: 0,
                        selectedAssetPath: 'assets/images/ic_share.svg',
                        unselectedAssetPath: 'assets/images/navitem1.svg',
                      ),
                      const SizedBox(height: 42),
                      _buildNavItem(
                        index: 1,
                        selectedAssetPath: 'assets/images/search.svg',
                        unselectedAssetPath: 'assets/images/navitem2.svg',
                      ),
                      const SizedBox(height: 42),
                      _buildNavItem(
                        index: 2,
                        selectedAssetPath: 'assets/images/setting.svg',
                        unselectedAssetPath: 'assets/images/navitem3.svg',
                      ),
                    ],
                  ),
                ),
              ),
              Container(
                width: _leftWidth,
                child: secondPart(),
              ),
              GestureDetector(
                onHorizontalDragUpdate: (details) {
                  setState(() {
                    _leftWidth += details.delta.dx;
                    _leftWidth = _leftWidth.clamp(_minLeftWidth, _maxLeftWidth);
                  });
                },
                child: MouseRegion(
                  cursor: SystemMouseCursors.resizeColumn,
                  child: Container(
                    width: 1.3,
                    color: Theme.of(context)
                        .flixColors
                        .text
                        .tertiary
                        .withOpacity(0.05),
                  ),
                ),
              ),
              Expanded(
                child: thirdPart(),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildNavItem({
    required int index,
    required String selectedAssetPath,
    required String unselectedAssetPath,
  }) {
    bool isSelected = index == selectedIndex;
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: () {
          setSelectedIndex(index);
          setState(() {
            thirdWidget = null;
          });
        },
        child: Padding(
          padding: const EdgeInsets.symmetric(),
          child: SvgPicture.asset(
            isSelected ? selectedAssetPath : unselectedAssetPath,
            width: 25,
            height: 25,
            colorFilter: ColorFilter.mode(
              getNavItemColor(context, index, selectedIndex),
              BlendMode.srcIn,
            ),
          ),
        ),
      ),
    );
  }

  Color getNavItemColor(BuildContext context, int index, int selectedIndex) {
    if (index == selectedIndex) {
      return Theme.of(context).flixColors.text.primary;
    } else {
      return Theme.of(context).flixColors.text.secondary;
    }
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
        return SettingsScreen(
          crossDeviceCallback: () {
            setState(() {
              thirdWidget = CrossDeviceClipboardScreen();
            });
          },
          goVersionScreen: () {
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
          },
          goManualAddCallback: () {
            setState(() {
              thirdWidget = const AddDeviceScreen();
            });
          },
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
          goGeneralCallback: () {
            setState(() {
              thirdWidget = GeneralScreen(
                showBack: false,
              );
            });
          },
          goSettingFunctionCallback: () {
            setState(() {
              thirdWidget = SettingFunctionScreen(
                showBack: false,
                crossDeviceCallback: () {
                  setState(() {
                    thirdWidget = CrossDeviceClipboardScreen();
                  });
                },
              );
            });
          },
          goAutomaticReceiveCallback: () {
            setState(() {
              thirdWidget = AutomaticReceivenScreen(
                showBack: false,
              );
            });
          },
          goSettingPravicyScreen: () {
            setState(() {
              thirdWidget = SettingPravicyScreen(
                showBack: false,
              );
            });
          },
          goSettingAgreementScreen: () {
            setState(() {
              thirdWidget = SettingAgreementScreen(
                showBack: false,
              );
            });
          },
          goLoginPage: () {
            setState(() {
              thirdWidget = LoginPage(
                showBack: false,
                goPayScreen: () {
                  setState(() {
                    thirdWidget = PayScreen(
                        //showBack: false,
                        );
                  });
                },
              );
            });
          },
          goCloudScreenPage: () {
            setState(() {
              thirdWidget = CloudScreenPage(
                  //  showBack: false,
                  );
            });
          },
          goPayScreen: () {
            setState(() {
              thirdWidget = PayScreen(
                  //showBack: false,
                  );
            });
          },
          goHotkeyScreen: () {
            setState(() {
              thirdWidget = HotkeyScreen(
                showBack: false,
              );
            });
          },
          goClientDebugScreen: () {
            setState(() {
              thirdWidget = ClientInfoPage(
                onClosePressed: (context) {
                  clearThirdWidget();
                },
              );
            });
          }, goFileUploadServer: () { setState(() {
              thirdWidget = FileUploadServer(
               
              );
            }); },
        );

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
