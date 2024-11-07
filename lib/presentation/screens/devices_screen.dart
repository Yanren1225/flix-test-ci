import 'dart:convert';
import 'dart:io';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:easy_refresh/easy_refresh.dart';
import 'package:figma_squircle/figma_squircle.dart';
import 'package:flix/domain/device/device_manager.dart';
import 'package:flix/domain/log/flix_log.dart';
import 'package:flix/domain/notification/badge_service.dart';
import 'package:flix/model/device_info.dart';
import 'package:flix/model/wifi_or_ap_name.dart';
import 'package:flix/network/multicast_client_provider.dart';
import 'package:flix/network/protocol/device_modal.dart';
import 'package:flix/presentation/basic/corner/flix_decoration.dart';
import 'package:flix/presentation/style/colors/flix_color.dart';
import 'package:flix/presentation/widgets/basic/icon_label_button.dart';
import 'package:flix/presentation/widgets/device_name/name_edit_bottom_sheet.dart';
import 'package:flix/presentation/widgets/devices/device_list.dart';
import 'package:flix/presentation/widgets/menu/main_menu.dart';
import 'package:flix/presentation/widgets/net/net_info_bottom_sheet.dart';
import 'package:flix/resource_extension.dart';
import 'package:flix/theme/theme_extensions.dart';
import 'package:flix/utils/android/android_utils.dart';
import 'package:flix/utils/device/device_utils.dart';
import 'package:flix/utils/permission/flix_permission_utils.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:modals/modals.dart';
import 'package:path_provider/path_provider.dart';

import '../../l10n/l10n.dart';

final _menuKey = GlobalKey(debugLabel: "pair_device_menu");

class DeviceScreen extends StatefulWidget {
  final void Function(DeviceInfo deviceInfo, bool isHistory) onDeviceSelected;
  final void Function()? onViewConnectInfo;
  final void Function()? onGoManualAdd;

  const DeviceScreen(
      {super.key,
      required this.onDeviceSelected,
      this.onViewConnectInfo,
      this.onGoManualAdd});

  @override
  // ignore: no_logic_in_create_state
  State<StatefulWidget> createState() => _DeviceScreenState();
}

class _DeviceScreenState extends State<DeviceScreen>
    with RouteAware, WidgetsBindingObserver {
  final _badges = BadgeService.instance.badges;
  List<DeviceInfo> devices = List.empty(growable: true);
  final _refreshController = EasyRefreshController();
  bool isFirewallAllowed = true;

  @override
  Widget build(BuildContext context) {
    final deviceProvider = MultiCastClientProvider.of(context, listen: true);
    devices = deviceProvider.deviceList.map((d) => d.toDeviceInfo()).toList();
    return Scaffold(
      body: Container(
        decoration: FlixDecoration(
            color: Theme.of(context).flixColors.background.secondary),
        child: Stack(
          children: [
            Column(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: EdgeInsets.only(
                      left: 20,
                      top: MediaQuery.paddingOf(context).top + 33,
                      right: 20,
                      bottom: 15),
                  child: Row(
                    mainAxisSize: MainAxisSize.max,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      SvgPicture.asset(context.imagePath("slogan.svg")),
                      Row(
                        children: [
                          Visibility(
                            visible: true,
                            child: Container(
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.04),
                                    offset: const Offset(0, 4),
                                    blurRadius: 6,
                                  ),
                                ],
                              ),
                              child: InkWell(
                                onTap: () {
                                  _refreshDevice();
                                },
                                child: ClipOval(
                                  // Ensures the child respects the circular shape
                                  child: SvgPicture.asset(
                                    context.imagePath("ic_refresh_menu.svg"),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          ModalAnchor(
                            key: _menuKey,
                            tag: "open_menu",
                            child: Container(
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.04),
                                    offset: const Offset(0, 4),
                                    blurRadius: 6,
                                  ),
                                ],
                              ),
                              child: SizedBox(
                                width: 36,
                                height: 36,
                                child: IconButton(
                                  splashRadius: 36,
                                  padding: EdgeInsets.zero,
                                  icon: SvgPicture.asset(
                                    context.imagePath("ic_open_menu.svg"),
                                    width: 36,
                                    height: 36,
                                  ),
                                  onPressed: () {
                                    showMainMenu(
                                      context,
                                      'open_menu',
                                      widget.onViewConnectInfo,
                                      widget.onGoManualAdd,
                                    );
                                  },
                                ),
                              ),
                            ),
                          )
                        ],
                      )
                    ],
                  ),
                ),
                if (!isFirewallAllowed)
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 16),
                  padding: const EdgeInsets.all(10),
                  decoration: ShapeDecoration(
                    color: const Color(0xFFFF3B30),
                    shape: SmoothRectangleBorder(
                      borderRadius: SmoothBorderRadius(
                        cornerRadius: 15,
                        cornerSmoothing: 0.6,
                      ),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start, 
                    children: [
                      const Text(
                        '检测到防火墙未放行，可能会导致无法发现设备、传输异常等问题。',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                        ),
                      ),
                    
                      Align(
                        alignment: Alignment.centerRight, 
                        child: SizedBox(
                          width: 55, 
                          height: 28, 
                          child: ElevatedButton(
                            onPressed: () {
                              runFirewallScript();
                            },
                            style: ElevatedButton.styleFrom(
                              padding: EdgeInsets.zero, 
                              backgroundColor: Color.fromRGBO(255, 255, 255, 0.3), 
                              shadowColor: Colors.transparent, 
                              elevation: 0, 
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(15),
                              ),
                              splashFactory: NoSplash.splashFactory, 
                              surfaceTintColor: Colors.transparent, 
                            ),
                            child: const Center( 
                              child: Text(
                                '修复',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Visibility(
                  //  visible: isMobile(),
                  child: Padding(
                    padding: const EdgeInsets.only(
                        left: 16, right: 16, top: 0, bottom: 0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      mainAxisSize: MainAxisSize.max,
                      children: [
                        Expanded(
                          child: StreamBuilder<String>(
                              initialData: deviceProvider.deviceName,
                              stream: deviceProvider.deviceNameStream.stream,
                              builder: (BuildContext context,
                                  AsyncSnapshot<String> snapshot) {
                                return IconLabelButton(
                                  icon: 'assets/images/ic_device.svg',
                                  label: snapshot.requireData,
                                  isLeft: true,
                                  onTap: () {
                                    showCupertinoModalPopup(
                                        context: context,
                                        builder: (context) {
                                          return const NameEditBottomSheet();
                                        });
                                  },
                                );
                              }),
                        ),
                        const SizedBox(width: 4),
                        Expanded(child: _buildNetworkInfoWidget(deviceProvider))
                      ],
                    ),
                  ),
                ),
                Expanded(
                  child: EasyRefresh(
                    controller: _refreshController,
                    callRefreshOverOffset: 1,
                    onRefresh: () async {
                      DeviceManager.instance.clearDevicesExcludeManual();
                      deviceProvider.startScan();
                      // onFinishListener(from){
                      //   talker.debug("addOnFinishListener refresh from = $from");
                      //   // DiscoverManager.instance.removeOnFinishListener(onFinishListener);
                      // }
                      // DiscoverManager.instance.addOnFinishListener(onFinishListener);
                      return IndicatorResult.success;
                    },
                    header: MaterialHeader(
                        color: FlixColor.blue,
                        backgroundColor:
                            Theme.of(context).flixColors.background.primary),
                    child: CustomScrollView(
                      slivers: [
                        const SliverPadding(padding: EdgeInsets.only(top: 5)),
                        StreamBuilder(
                            stream: deviceProvider.history,
                            builder: (context, snapshot) {
                              return DeviceList(
                                devices: devices,
                                onDeviceSelected: widget.onDeviceSelected,
                                showHistory: true,
                                history: snapshot.data?.toList() ?? [],
                                badges: _badges,
                                onHistoryDelete: (item) {
                                  deviceProvider.deleteHistory(item.id);
                                },
                              );
                            })
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  StreamBuilder<ConnectivityResult> _buildNetworkInfoWidget(
      MultiCastClientProvider deviceProvider) {
    return StreamBuilder<ConnectivityResult>(
        initialData: deviceProvider.connectivityResult,
        stream: deviceProvider.connectivityResultStream.stream,
        builder:
            (BuildContext context, AsyncSnapshot<ConnectivityResult> snapshot) {
          final connectivityResult = snapshot.data;
          if (connectivityResult == ConnectivityResult.wifi ||
              connectivityResult == ConnectivityResult.p2pWifi) {
            return StreamBuilder<WifiOrApName>(
                initialData: deviceProvider.wifiOrApName,
                stream: deviceProvider.wifiOrApNameStream,
                builder: (BuildContext context,
                    AsyncSnapshot<WifiOrApName> snapshot) {
                  final isAp = snapshot.requireData.isAp;
                  String name = snapshot.requireData.name;
                  if (name.isEmpty) {
                    name = S.of(context).device_ap_connected;
                  }
                  return IconLabelButton(
                    icon: isAp
                        ? 'assets/images/ic_ap.svg'
                        : 'assets/images/ic_wifi.svg',
                    label: name,
                    iconColor: FlixColor.blue,
                    isLeft: false,
                    onTap: () {
                      showNetInfoBottomSheet(
                          context,
                          deviceProvider.apName,
                          deviceProvider.wifiName.isEmpty
                              ? S.of(context).device_wifi_connected
                              : deviceProvider.wifiName);
                    },
                  );
                });
          } else if (connectivityResult == ConnectivityResult.none) {
            return IconLabelButton(
              icon: 'assets/images/ic_no_wifi.svg',
              label: S.of(context).device_no_network,
              iconColor: FlixColor.red,
              labelColor: FlixColor.red,
              isLeft: false,
              onTap: () {
                AndroidUtils.openWifiSettings();
              },
            );
          } else {
            return IconLabelButton(
                icon: 'assets/images/ic_no_wifi.svg',
                label: S.of(context).device_wifi_not_connected,
                iconColor: FlixColor.red,
                labelColor: FlixColor.red,
                isLeft: false,
                onTap: () {
                  AndroidUtils.openWifiSettings();
                });
          }
        });
  }




  Future<bool> checkFirewall() async {

      ProcessResult result = await Process.run(
      'powershell',
      ['-Command', 'Get-NetFirewallProfile -Profile Domain,Public,Private | Select-Object -Property Enabled']
    );
    String output = result.stdout.toString();

    if (output.contains("False")) {
     return true;
     } else {
       String exePath =
          Platform.resolvedExecutable.replaceAll('/', '\\').toLowerCase();
      try {
        var result = await Process.run('powershell', [
          '-Command',
          '''
              Get-NetFirewallRule | Where-Object { \$_.DisplayName -like "flix" -and \$_.Enabled -eq "True" -and \$_.Action -eq "Allow" } | Get-NetFirewallApplicationFilter | Where-Object { \$_.Program -eq "$exePath" };
              '''
        ]);
        if (result.stdout != null &&
            result.stdout.toString().toLowerCase().contains(exePath)) {
          return true;
        } else {
          return false;
        }
      } catch (e) {
        return true;
      }
    }
  }

  Future<void> runFirewallScript() async {
    String exePath = Platform.resolvedExecutable.replaceAll('/', '\\').toLowerCase();
    try {

      final tempDir = await getTemporaryDirectory();
      final scriptDirPath = '${tempDir.path}\\flix\\firewall';
      final scriptDir = Directory(scriptDirPath);

  
      if (!scriptDir.existsSync()) {
        await scriptDir.create(recursive: true);
      }

    
      final filePath = '${scriptDir.path}\\run_script.ps1';
      final ps1File = File(filePath);


      final scriptContent = '''
  Write-Output "正在添加Flix到防火墙，请勿关闭此窗口..."\r\n
  Function Test-Admin {\r\n
      \$currentUser = New-Object Security.Principal.WindowsPrincipal([Security.Principal.WindowsIdentity]::GetCurrent())\r\n
      return \$currentUser.IsInRole([Security.Principal.WindowsBuiltinRole]::Administrator)\r\n
  }\r\n
  \r\n
  if (-not (Test-Admin)) {\r\n
      Start-Process powershell -ArgumentList "-File `"\$PSCommandPath`"" -Verb RunAs\r\n
      exit\r\n
  }\r\n
  \r\n
  Remove-NetFirewallRule -DisplayName "flix"
  \r\n
  \r\n
  New-NetFirewallRule -DisplayName "flix" -Direction Inbound -Program "$exePath" -Action Allow -Enabled True\r\n
  ''';


      final bom = [0xEF, 0xBB, 0xBF];
      await ps1File.writeAsBytes(bom + utf8.encode(scriptContent), mode: FileMode.write);


      await Process.run('powershell', ['-File', filePath]);
      setState(() {
        isFirewallAllowed = true;
      });
      await checkFirewall();
    } catch (e) {
    }
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    BadgeService.instance.addOnBadgesChangedListener(_onBadgesChanged);
    FlixPermissionUtils.checkAccessWifiNamePermission(context).then((value) {
      if (value && mounted) {
        final deviceProvider =
            MultiCastClientProvider.of(context, listen: false);
        deviceProvider.resetWifiName();
      }
    });
    final deviceProvider = MultiCastClientProvider.of(context, listen: false);
    deviceProvider.connectivityResultStream.stream.listen((event) {
      if (event != ConnectivityResult.none &&
          event != ConnectivityResult.mobile) {
        _refreshDevice();
      }
    });
  }

  Future<void> _refreshDevice() async {
    // 先隐藏防火墙提示再检查防火墙
    setState(() {
      isFirewallAllowed = true;
    });
    _refreshController.callRefresh(overOffset: 6);
    if (Platform.isWindows) {
      bool isAllowed = await checkFirewall();
      if (mounted) {
        setState(() {
          isFirewallAllowed = isAllowed;
        });
      }
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    BadgeService.instance.removeOnBadgeChangedListener(_onBadgesChanged);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    if (state == AppLifecycleState.resumed) {
      final deviceProvider = MultiCastClientProvider.of(context, listen: false);
      deviceProvider.resetWifiName();
    }
  }

  void _onBadgesChanged(Map<String, int> badges) {
    if (!mounted) {
      talker.warning('context has unmounted');
      return;
    }

    Future.delayed(Duration.zero, () {
      setState(() {});
    });
  }
}

class HistoryItem extends StatefulWidget {
  final int index;
  final DeviceInfo historyItemInfo;
  final VoidCallback onTap;
  final void Function(DeviceInfo deviceInfo) onDelete;
  final void Function(DeviceInfo) onManualConnect;
  final bool selected;

  const HistoryItem(
      {Key? key,
      required this.index,
      required this.historyItemInfo,
      this.selected = false,
      required this.onTap,
      required this.onDelete,
      required this.onManualConnect})
      : super(key: key);

  @override
  _HistoryItemState createState() => _HistoryItemState();
}

class _HistoryItemState extends State<HistoryItem> {
  double _translateX = 0;
  final double _maxSlide = Platform.isAndroid || Platform.isIOS
                                  ? 80
                                  : 70;

  void _handlePanUpdate(DragUpdateDetails details) {
    setState(() {
      _translateX += details.delta.dx;

      if (_translateX < -_maxSlide) {
        _translateX = -_maxSlide;
      } else if (_translateX > 0) {
        _translateX = 0;
      }
    });
  }

  void _handlePanEnd(DragEndDetails details) {
    setState(() {
      if (_translateX < -_maxSlide / 2) {
        _translateX = -_maxSlide;
      } else {
        _translateX = 0;
      }
    });
  }

  void _handleSecondaryTapDown(TapDownDetails details) {
    setState(() {
      if (_translateX == 0) {
        _translateX = -_maxSlide;
      } else {
        _translateX = 0;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: GestureDetector(
        onPanUpdate: _handlePanUpdate,
        onPanEnd: _handlePanEnd,
        onSecondaryTapDown: _handleSecondaryTapDown,
        child: Stack(
          children: [
            Positioned.fill(
              child: Align(
                alignment: Alignment.centerRight,
                child: Padding(
                  padding: const EdgeInsets.only(right: 16),
                  child: TapRegion(
                    onTapInside: (tap) {
                      setState(() {
                        _translateX = 0;
                      });
                      widget.onDelete(widget.historyItemInfo);
                    },
                    onTapOutside: (tap) {
                      setState(() {
                        _translateX = 0;
                      });
                    },
                    child: Container(
                      width: Platform.isAndroid || Platform.isIOS
                                  ? 70
                                  : 60,
                      height: Platform.isAndroid || Platform.isIOS
                                  ? 70
                                  : 60,
                      decoration: ShapeDecoration(
                        color: Theme.of(context).flixColors.background.primary,
                        shape: SmoothRectangleBorder(
                          borderRadius: SmoothBorderRadius(
                            cornerRadius: 15,
                            cornerSmoothing: 0.6,
                          ),
                        ),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SvgPicture.asset(
                            'assets/images/del_device.svg',
                            width: Platform.isAndroid || Platform.isIOS
                                  ? 22
                                  : 20,
                            height: Platform.isAndroid || Platform.isIOS
                                  ? 22
                                  : 20,
                          ),
                          const SizedBox(height: 2),
                          Text(
                            "删除",
                            style: TextStyle(
                              color: Colors.red,
                              fontSize: Platform.isAndroid || Platform.isIOS
                                  ? 13.5
                                  : 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              transform: Matrix4.translationValues(_translateX, 0, 0),
              child: InkWell(
                onTap: widget.onTap,
                child: Padding(
                  padding: const EdgeInsets.only(left: 16, right: 16),
                  child: SizedBox(
                    child: DecoratedBox(
                      decoration: ShapeDecoration(
                        shadows: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.04),
                            offset: const Offset(0, 4),
                            blurRadius: 6,
                          ),
                        ],
                        color: Theme.of(context).brightness == Brightness.dark
                            ? (widget.selected
                                ? const Color.fromRGBO(28, 28, 30, 1)
                                : Theme.of(context).colorScheme.surface)
                            : (widget.selected
                                ? const Color.fromRGBO(232, 243, 255, 1)
                                : Theme.of(context).colorScheme.surface),
                        shape: SmoothRectangleBorder(
                          borderRadius: SmoothBorderRadius(
                            cornerRadius: 15,
                            cornerSmoothing: 0.6,
                          ),
                          side: widget.selected
                              ? const BorderSide(
                                  color: Color.fromRGBO(0, 122, 255, 1),
                                  width: 1.4,
                                )
                              : BorderSide.none,
                        ),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(13),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Image(
                              image: Theme.of(context).brightness ==
                                      Brightness.dark
                                  ? AssetImage(
                                      'assets/images/dark_noconnect_${widget.historyItemInfo.icon}')
                                  : AssetImage(
                                      'assets/images/noconnect_${widget.historyItemInfo.icon}'),
                              width: Platform.isAndroid || Platform.isIOS
                                  ? 44
                                  : 34,
                              height: Platform.isAndroid || Platform.isIOS
                                  ? 44
                                  : 34,
                              fit: BoxFit.fill,
                            ),
                            SizedBox(
                                width: Platform.isAndroid || Platform.isIOS
                                    ? 12
                                    : 10),
                            Expanded(
                              child: Text(
                                widget.historyItemInfo.name,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontSize: Platform.isAndroid || Platform.isIOS
                                      ? 16
                                      : 14,
                                  color: Theme.of(context)
                                      .textTheme
                                      .bodyLarge!
                                      .color,
                                  //fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                            Visibility(
                              visible: widget.historyItemInfo.from ==
                                  DeviceFrom.manual,
                              child: Padding(
                                padding: const EdgeInsets.only(left: 10),
                                child: AnimatedCrossFade(
                                  duration: const Duration(milliseconds: 80),
                                  firstChild: TextButton(
                                    style: ButtonStyle(
                                      backgroundColor: MaterialStateProperty.all(Color.fromARGB(26, 0, 122, 255)),
                                    ),
                                    onPressed: () {
                                      widget.onManualConnect(
                                          widget.historyItemInfo);
                                    },
                                    child: const Text(
                                      "连接",
                                      style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w500,
                                          color: Color.fromARGB(255, 0, 122, 255)
                                      ),
                                    ),
                                  ),
                                  secondChild: TextButton(
                                    style: ButtonStyle(
                                      backgroundColor: MaterialStateProperty.all(const Color.fromARGB(26, 0, 122, 255)),
                                    ),
                                    onPressed: () {

                                    },
                                    child: const Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      crossAxisAlignment: CrossAxisAlignment.center,
                                      children: [

                                        Text(
                                          "连接中",
                                          style: TextStyle(
                                              fontSize: 14,
                                              fontWeight: FontWeight.w500,
                                              color: Color.fromARGB(255, 0, 122, 255)
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  crossFadeState: widget.historyItemInfo.isConnecting ? CrossFadeState.showSecond : CrossFadeState.showFirst,
                                ),
                              ),
                            ),
                            const SizedBox(width: 10),
                            SvgPicture.asset(
                              'assets/images/arrow_right.svg',
                              width: 24,
                              height: 24,
                              colorFilter: ColorFilter.mode(
                                  Theme.of(context).flixColors.text.secondary,
                                  BlendMode.srcIn),
                            )
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
