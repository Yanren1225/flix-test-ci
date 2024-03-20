import 'package:flix/model/device_info.dart';
import 'package:flix/network/multicast_client_provider.dart';
import 'package:flix/presentation/screens/devices_screen.dart';
import 'package:flix/presentation/widgets/devices/device_item.dart';
import 'package:flix/utils/meida/media_utils.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

class DeviceList extends StatefulWidget {
  const DeviceList(
      {super.key,
      required this.devices,
      required this.onDeviceSelected,
      required this.showHistory,
      required this.history,
      this.badges = const <String, int>{}});

  final List<DeviceInfo> devices;
  final void Function(DeviceInfo deviceInfo) onDeviceSelected;
  final bool showHistory;
  final List<DeviceInfo> history;
  final Map<String, int> badges;

  @override
  _DeviceListState createState() => _DeviceListState();
}

class _DeviceListState extends State<DeviceList> {
  List<DeviceInfo> get devices => widget.devices;

  void Function(DeviceInfo deviceInfo) get onDeviceSelected =>
      widget.onDeviceSelected;

  bool get showHistory => widget.showHistory;

  List<DeviceInfo> get history => widget.history;

  Map<String, int> get badges => widget.badges;

  var selectedIndex = -1;

  @override
  Widget build(BuildContext context) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      ...List.generate(devices.length, (index) {
        var deviceInfo = devices[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: 10, left: 16, right: 16),
          child: DeviceItem(
            ValueKey(devices[index].id),
            deviceInfo,
            () {
              onDeviceSelected(deviceInfo);
              setState(() {
                selectedIndex = index;
              });
            },
            selected: isOverMediumWidth(context) ? selectedIndex == index : false,
            badge: badges[deviceInfo.id] ?? 0,
          ),
        );
      }),
      Visibility(
        visible: showHistory && history.isNotEmpty,
        child: Padding(
          padding: EdgeInsets.only(left: 16, right: 16, top: 20, bottom: 6),
          child: InkWell(
            onTap: () {
              MultiCastClientProvider.of(context).clearDevices();
            },
            child: const Text(
              '历史记录',
              style: TextStyle(
                  color: Color.fromRGBO(60, 60, 67, 0.6),
                  fontSize: 14,
                  fontWeight: FontWeight.w500),
            ),
          ),
        ),
      ),
      ...List.generate(showHistory ? history.length : 0, (index) {
        var historyItemInfo = history[index];
        return HistoryItem(historyItemInfo: historyItemInfo);
      }),
      const Expanded(child: SizedBox())
    ]);
  }
}
