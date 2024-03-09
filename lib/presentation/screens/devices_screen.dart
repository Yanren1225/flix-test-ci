import 'package:flix/model/device_info.dart';
import 'package:flix/network/multicast_client_provider.dart';
import 'package:flix/presentation/widgets/devices/device_list.dart';
import 'package:flix/utils/device/device_utils.dart';
import 'package:flix/utils/notification_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:lottie/lottie.dart';

import 'concert/concert_screen.dart';

class DeviceScreen extends StatefulWidget {
  final void Function(DeviceInfo deviceInfo) onDeviceSelected;

  const DeviceScreen({super.key, required this.onDeviceSelected});

  @override
  // ignore: no_logic_in_create_state
  State<StatefulWidget> createState() => _DeviceScreenState();
}

class _DeviceScreenState extends State<DeviceScreen> {
  // var devices = <DeviceInfo>[];
  // var history = <DeviceInfo>[];

  // _DeviceScreenState(this.devices, this.history);

  @override
  Widget build(BuildContext context) {
    final deviceProvider = MultiCastClientProvider.of(context, listen: true);
    final devices =
        deviceProvider.deviceList.map((d) => d.toDeviceInfo()).toList();
    final history = <DeviceInfo>[];
    return Container(
      decoration:
          const BoxDecoration(color: Color.fromARGB(255, 247, 247, 247)),
      child: Stack(
        children: [
          SizedBox(
              width: double.infinity,
              height: 120,
              child: Lottie.asset('assets/animations/radar.json',
                  fit: BoxFit.cover,
              alignment: Alignment.topRight)),
          SafeArea(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                    padding: const EdgeInsets.only(
                        top: 60, left: 20, right: 20, bottom: 10),
                    child: InkWell(
                      onTap: () async {
                        MultiCastClientProvider.of(context).startScan();
                      },
                      child: const Text('附近设备',
                          style: TextStyle(
                              color: Colors.black,
                              fontSize: 36.0,
                              fontWeight: FontWeight.normal)),
                    )),
                Expanded(
                    child: DeviceList(devices: devices, onDeviceSelected: widget.onDeviceSelected, showHistory: true, history: history))
              ],
            ),
          ),
        ],
      ),
    );
  }
}



class HistoryItem extends StatelessWidget {
  final DeviceInfo historyItemInfo;

  const HistoryItem({Key? key, required this.historyItemInfo})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 20, right: 10, top: 10, bottom: 10),
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
    );
  }
}
