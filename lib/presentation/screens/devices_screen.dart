import 'dart:developer';
import 'dart:io';

import 'package:flix/domain/log/flix_log.dart';
import 'package:flix/domain/notification/BadgeService.dart';
import 'package:flix/domain/notification/NotificationService.dart';
import 'package:flix/model/device_info.dart';
import 'package:flix/model/notification/reception_notification.dart';
import 'package:flix/network/multicast_client_provider.dart';
import 'package:flix/presentation/widgets/devices/device_list.dart';
import 'package:flix/presentation/widgets/segements/cupertino_navigation_scaffold.dart';
import 'package:flix/presentation/widgets/super_title.dart';
import 'package:flix/utils/device/device_utils.dart';
import 'package:flix/utils/notification_utils.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:lottie/lottie.dart';
import 'package:modals/modals.dart';

import 'concert/concert_screen.dart';

class DeviceScreen extends StatefulWidget {
  final void Function(DeviceInfo deviceInfo) onDeviceSelected;

  const DeviceScreen({super.key, required this.onDeviceSelected});

  @override
  // ignore: no_logic_in_create_state
  State<StatefulWidget> createState() => _DeviceScreenState();
}

class _DeviceScreenState extends State<DeviceScreen> with RouteAware {
  final _badges = BadgeService.instance.badges;

  @override
  Widget build(BuildContext context) {
    final deviceProvider = MultiCastClientProvider.of(context, listen: true);
    final devices =
        deviceProvider.deviceList.map((d) => d.toDeviceInfo()).toList();
    final history =
        deviceProvider.history.map((d) => d.toDeviceInfo()).toList();
    return Container(
      decoration:
          const BoxDecoration(color: Color.fromARGB(255, 247, 247, 247)),
      child: Stack(
        children: [
          InkWell(
            onTap: () => deviceProvider.startScan(),
            child: CupertinoNavigationScaffold(
              title: '附近设备',
              isSliverChild: true,
              child: DeviceList(
                devices: devices,
                onDeviceSelected: widget.onDeviceSelected,
                showHistory: true,
                history: history,
                badges: _badges,
              ),
            ),
          ),
          SizedBox(
              width: double.infinity,
              height: 120,
              child: Lottie.asset('assets/animations/radar.json',
                  fit: BoxFit.cover, alignment: Alignment.topRight)),
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
  final DeviceInfo historyItemInfo;

  const HistoryItem({Key? key, required this.historyItemInfo})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        Navigator.of(context).push(MaterialPageRoute(
            builder: (context) => ConcertScreen(
                  deviceInfo: historyItemInfo,
                  showBackButton: true,
                  playable: false,
                )));
      },
      child: Padding(
        padding:
            const EdgeInsets.only(left: 20, right: 10, top: 10, bottom: 10),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Row(
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
                Text(historyItemInfo.name,
                    style: const TextStyle(
                        fontSize: 14,
                        color: Colors.black,
                        fontWeight: FontWeight.w500))
              ],
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
    );
  }
}
