import 'package:flix/domain/bubble_pool.dart';
import 'package:flix/domain/log/flix_log.dart';
import 'package:flix/domain/notification/BadgeService.dart';
import 'package:flix/model/device_info.dart';
import 'package:flix/network/multicast_client_provider.dart';
import 'package:flix/presentation/widgets/devices/device_list.dart';
import 'package:flix/presentation/widgets/segements/cupertino_navigation_scaffold.dart';
import 'package:flix/utils/device/device_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_svg/svg.dart';
import 'package:flutter_swipe_action_cell/flutter_swipe_action_cell.dart';
import 'package:lottie/lottie.dart';

class DeviceScreen extends StatefulWidget {
  final void Function(DeviceInfo deviceInfo, bool isHistory) onDeviceSelected;

  const DeviceScreen({super.key, required this.onDeviceSelected});

  @override
  // ignore: no_logic_in_create_state
  State<StatefulWidget> createState() => _DeviceScreenState();
}

class _DeviceScreenState extends State<DeviceScreen> with RouteAware {
  final _badges = BadgeService.instance.badges;
  List<DeviceInfo> history = List.empty(growable: true);
  List<DeviceInfo> devices = List.empty(growable: true);

  @override
  Widget build(BuildContext context) {
    final deviceProvider = MultiCastClientProvider.of(context, listen: true);
    history = deviceProvider.history.map((d) => d.toDeviceInfo()).toList();
    devices = deviceProvider.deviceList.map((d) => d.toDeviceInfo()).toList();
    return Container(
      decoration:
          const BoxDecoration(color: Color.fromARGB(255, 247, 247, 247)),
      child: Stack(
        children: [
          InkWell(
            onTap: () =>
                MultiCastClientProvider.of(context, listen: false).startScan(),
            child: CupertinoNavigationScaffold(
                title: '附近设备',
                isSliverChild: true,
                padding: 16,
                enableRefresh: true,
                child: DeviceList(
                  devices: devices,
                  onDeviceSelected: widget.onDeviceSelected,
                  showHistory: true,
                  history: history,
                  badges: _badges,
                  onHistoryDelete: (item) {
                    deviceProvider.deleteHistory(item.id);
                  },
                )),
          ),
          ClipRect(
            child: SizedBox(
                width: double.infinity,
                height: 140,
                child: Lottie.asset('assets/animations/radar.json',
                    fit: BoxFit.cover, alignment: Alignment.topRight)),
          ),
        ],
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    BadgeService.instance.addOnBadgesChangedListener(_onBadgesChanged);
  }

  @override
  void dispose() {
    BadgeService.instance.removeOnBadgeChangedListener(_onBadgesChanged);
    super.dispose();
  }

  void _onBadgesChanged(Map<String, int> badges) {
    if (!context.mounted) {
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

  HistoryItem(
      {Key? key,
      required this.index,
      required this.historyItemInfo,
      required this.onTap,
      required this.onDelete})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SwipeActionCell(
      key: ValueKey(historyItemInfo.id),
      index: index,
      controller: _swipeActionController,
      backgroundColor: Color.fromRGBO(247, 247, 247, 1),
      trailingActions: <SwipeAction>[
        SwipeAction(
            backgroundRadius: 6,
            color: Color.fromRGBO(255, 59, 48, 1),
            title: '删除',
            style: TextStyle(color: Colors.white, fontSize: 14),
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
          padding:
              const EdgeInsets.only(left: 20, right: 10, top: 10, bottom: 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SvgPicture.asset(
                'assets/images/history.svg',
                width: 20,
                height: 20,
              ),
              const SizedBox(
                width: 6,
              ),
              Expanded(
                child: Text(historyItemInfo.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                        fontSize: 14,
                        color: Colors.black,
                        fontWeight: FontWeight.w500)),
              ),
              const SizedBox(
                width: 16,
              ),
              SvgPicture.asset(
                'assets/images/arrow_right.svg',
                width: 20,
                height: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
