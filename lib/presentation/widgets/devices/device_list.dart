import 'package:flix/model/device_info.dart';
import 'package:flix/network/multicast_client_provider.dart';
import 'package:flix/presentation/screens/devices_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

class DeviceList extends StatelessWidget {
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
  Widget build(BuildContext context) {
    return ListView(
      physics: const BouncingScrollPhysics(
          decelerationRate: ScrollDecelerationRate.fast),
      children: [
        ...List.generate(devices.length, (index) {
          var deviceInfo = devices[index];
          return GestureDetector(
            onTap: () {
              onDeviceSelected(deviceInfo);
            },
            child: Padding(
              padding: const EdgeInsets.only(bottom: 10, left: 16, right: 16),
              child: DeviceItem(
                Key(devices[index].id),
                deviceInfo,
                badge: badges[deviceInfo.id] ?? 0,
              ),
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
              child: Text(
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
        })
      ],
    );
  }
}

class DeviceItem extends StatelessWidget {
  final DeviceInfo deviceInfo;
  final int badge;

  const DeviceItem(Key key, this.deviceInfo, {this.badge = 0})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.all(Radius.circular(20))),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Flexible(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  badge > 0
                      ? Badge(
                          backgroundColor: Colors.red,
                          textColor: Colors.white,
                          label: badge > 9
                              ? const Padding(padding: EdgeInsets.symmetric(horizontal: 4), child: const Text('9+'))
                              : SizedBox(width: 16, height:16, child: Center(child: Text('$badge'))),
                          padding: EdgeInsets.zero,
                          child: Image(
                            image:
                                AssetImage('assets/images/${deviceInfo.icon}'),
                            width: 36,
                            height: 36,
                            fit: BoxFit.fill,
                          ),
                        )
                      : Image(
                          image: AssetImage('assets/images/${deviceInfo.icon}'),
                          width: 36,
                          height: 36,
                          fit: BoxFit.fill,
                        ),
                  const SizedBox(
                    width: 10,
                  ),
                  Flexible(
                    child: Text(
                      deviceInfo.name,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                          color: Colors.black,
                          fontSize: 14,
                          fontWeight: FontWeight.w500),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(
              width: 16,
            ),
            SvgPicture.asset(
              'assets/images/arrow_right.svg',
              width: 24,
              height: 24,
            ),
          ],
        ),
      ),
    );
  }
}
