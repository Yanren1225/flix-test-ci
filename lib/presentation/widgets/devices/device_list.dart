import 'package:flix/model/device_info.dart';
import 'package:flix/network/multicast_client_provider.dart';
import 'package:flix/presentation/screens/devices_screen.dart';
import 'package:flix/presentation/widgets/devices/device_item.dart';
import 'package:flix/theme/theme_extensions.dart';
import 'package:flix/utils/meida/media_utils.dart';
import 'package:flix/utils/text/text_extension.dart';
import 'package:flutter/material.dart';
 
class DeviceList extends StatefulWidget {
  const DeviceList(
      {super.key,
      required this.devices,
      required this.onDeviceSelected,
      required this.showHistory,
      required this.history,
      this.onHistoryDelete,
      this.badges = const <String, int>{}});

  final List<DeviceInfo> devices;
  final void Function(DeviceInfo deviceInfo, bool isHistory) onDeviceSelected;
  final void Function(DeviceInfo deviceInfo)? onHistoryDelete;
  final bool showHistory;
  final List<DeviceInfo> history;
  final Map<String, int> badges;

  @override
  DeviceListState createState() => DeviceListState();
}

class DeviceListState extends State<DeviceList> {
  List<DeviceInfo> get devices => widget.devices;

  void Function(DeviceInfo deviceInfo, bool isHistory) get onDeviceSelected =>
      widget.onDeviceSelected;

  bool get showHistory => widget.showHistory;

  List<DeviceInfo> get history => widget.history;

  Map<String, int> get badges => widget.badges;

  @override
  Widget build(BuildContext context) {
    final deviceProvider = MultiCastClientProvider.of(context, listen: true);
    return SliverList.list(children: [
      ...List.generate(devices.length, (index) {
        var deviceInfo = devices[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: 10, left: 16, right: 16),
          child: DeviceItem(
            ValueKey(devices[index].id),
            deviceInfo,
            () {
              onDeviceSelected(deviceInfo, false);
              deviceProvider.setSelectedDeviceId(deviceInfo.id);
            },
            selected: isOverMediumWidth(context)
                ? deviceProvider.selectedDeviceId == deviceInfo.id
                : false,
            badge: badges[deviceInfo.id] ?? 0,
          ),
        );
      }),
      Visibility(
        visible: showHistory && history.isNotEmpty,
        child: const Padding(
          padding:
              EdgeInsets.only(left: 0, right: 0, top: 0, bottom: 0),
         
        ),
      ),
      ...List.generate(showHistory ? history.length : 0, (index) {
        var historyItemInfo = history[index];
        return HistoryItem(
          index: index,
          historyItemInfo: historyItemInfo,
          selected: isOverMediumWidth(context)
              ? deviceProvider.selectedDeviceId == historyItemInfo.id
              : false,
          onTap: () {
            onDeviceSelected(historyItemInfo, true);
            deviceProvider.setSelectedDeviceId(historyItemInfo.id);
          },
          onDelete: (item) {
            widget.onHistoryDelete?.call(item);
          },
        );
      }),
      const SizedBox(
        height: 40,
      )
      // const Expanded(child: SizedBox())
    ]);
  }
}
