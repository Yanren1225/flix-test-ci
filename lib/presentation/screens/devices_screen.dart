
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:easy_refresh/easy_refresh.dart';
import 'package:flix/domain/device/device_manager.dart';
import 'package:flix/domain/log/flix_log.dart';
import 'package:flix/domain/notification/badge_service.dart';
import 'package:flix/model/device_info.dart';
import 'package:flix/model/wifi_or_ap_name.dart';
import 'package:flix/network/discover/discover_manager.dart';
import 'package:flix/network/multicast_client_provider.dart';
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
import 'package:flix/utils/platform_utils.dart';
import 'package:flix/utils/text/text_extension.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:flutter_swipe_action_cell/flutter_swipe_action_cell.dart';
import 'package:modals/modals.dart';

import '../../l10n/l10n.dart';

final _menuKey = GlobalKey(debugLabel: "pair_device_menu");

class DeviceScreen extends StatefulWidget {
  final void Function(DeviceInfo deviceInfo, bool isHistory) onDeviceSelected;
  final void Function()? onViewConnectInfo;
  final void Function()? onGoManualAdd;

  const DeviceScreen({super.key, required this.onDeviceSelected, this.onViewConnectInfo, this.onGoManualAdd});

  @override
  // ignore: no_logic_in_create_state
  State<StatefulWidget> createState() => _DeviceScreenState();
}

class _DeviceScreenState extends State<DeviceScreen>
    with RouteAware, WidgetsBindingObserver {
  final _badges = BadgeService.instance.badges;
  List<DeviceInfo> history = List.empty(growable: true);
  List<DeviceInfo> devices = List.empty(growable: true);
  final _refreshController = EasyRefreshController();
 
  @override
  Widget build(BuildContext context) {
    final deviceProvider = MultiCastClientProvider.of(context, listen: true);
    history = deviceProvider.history.map((d) => d.toDeviceInfo()).toList();
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
                      bottom: 23),
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
                                child: ClipOval( // Ensures the child respects the circular shape
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
                Visibility(
                  visible: isMobile(),
                  child: Padding(
                    padding: const EdgeInsets.only(
                        left: 16, right: 16, top: 0, bottom: 16),
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
                        const SliverPadding(padding: EdgeInsets.only(top: 10)),
                        DeviceList(
                          devices: devices,
                          onDeviceSelected: widget.onDeviceSelected,
                          showHistory: true,
                          history: history,
                          badges: _badges,
                          onHistoryDelete: (item) {
                            deviceProvider.deleteHistory(item.id);
                          },
                        )
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

  void _refreshDevice() {
      _refreshController.callRefresh(overOffset: 6);
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






class HistoryItem extends StatelessWidget {
  final int index;
  final DeviceInfo historyItemInfo;
  
  final VoidCallback onTap;
  final void Function(DeviceInfo deviceInfo) onDelete;
  final SwipeActionController _swipeActionController = SwipeActionController();
  final bool selected;

  HistoryItem(
      {Key? key,
      required this.index,
      required this.historyItemInfo,
      this.selected = false,
      required this.onTap,
      required this.onDelete})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10), 
      child: SwipeActionCell(
        key: ValueKey(historyItemInfo.id),
        index: index,
        controller: _swipeActionController,
        backgroundColor: Theme.of(context).flixColors.background.secondary,
        trailingActions: <SwipeAction>[
          SwipeAction(
              backgroundRadius: 15, 
              color: const Color.fromARGB(255, 255, 255, 255),  
              title: S.of(context).device_delete,
              style: const TextStyle(
                  color: Color.fromRGBO(255, 59, 48, 1), 
                  fontSize: 14
              ).fix(),
              onTap: (CompletionHandler handler) async {
                onDelete(historyItemInfo);
                await handler(true);
              }),
        ],
        child: InkWell(
          onTap: onTap,
          onSecondaryTap: () {
            _swipeActionController.openCellAt(index: index, trailing: true);
          },
          child: Padding(
            padding: const EdgeInsets.only(left: 16, right: 16), 
            child: SizedBox(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: Theme.of(context).brightness == Brightness.dark
                      ? (selected
                          ? const Color.fromRGBO(28, 28, 30, 1)
                          : Theme.of(context).flixColors.background.primary)
                      : (selected
                          ? const Color.fromRGBO(232, 243, 255, 1)
                          : Theme.of(context).flixColors.background.primary),
                  borderRadius: BorderRadius.circular(15),  
                  border: Border.all(
                    color: selected
                        ? const Color.fromRGBO(0, 122, 255, 1)
                        : Theme.of(context).flixColors.background.primary,
                    width: 1.4,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.04),
                      offset: const Offset(0, 4),
                      blurRadius: 6,
                    ),
                  ],
                ),
                child: Padding(
                  padding: const EdgeInsets.all(13),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Image(
                        image:  Theme.of(context).brightness == Brightness.dark
                      ? AssetImage(
                            'assets/images/dark_noconnect_${historyItemInfo.icon}')
                      : 
                           AssetImage(
                            'assets/images/noconnect_${historyItemInfo.icon}'),
                        width: 34,
                        height: 34,
                        fit: BoxFit.fill,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          historyItemInfo.name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                                  fontSize: 14,
                                  color: Theme.of(context).flixColors.text.primary,
                                  fontWeight: FontWeight.w500)
                              .fix(),
                        ),
                      ),
                      const SizedBox(width: 16),
                      SvgPicture.asset(
                        'assets/images/arrow_right.svg',
                        width: 24,
                        height: 24,
                        colorFilter: ColorFilter.mode(
                            Theme.of(context).flixColors.text.secondary,
                            BlendMode.srcIn),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
