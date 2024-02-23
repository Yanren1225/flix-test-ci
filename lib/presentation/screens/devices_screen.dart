import 'package:androp/model/device_info.dart';
import 'package:androp/network/multicast_client_provider.dart';
import 'package:androp/utils/device/device_utils.dart';
import 'package:androp/utils/notification_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:lottie/lottie.dart';

import 'concert_screen.dart';

class DeviceScreen extends StatefulWidget {
  const DeviceScreen({super.key});

  @override
  // ignore: no_logic_in_create_state
  State<StatefulWidget> createState() => _DeviceScreenState(
      // [
      //   DeviceInfo("0", 0, 'Xiaomi 14', 'phone.webp'),
      //   DeviceInfo("1", 1, 'RedmiBook Pro 15 锐龙版', 'pc.webp'),
      //   DeviceInfo("2", 2, 'Xiaomi Pad 14 Max', 'pad.webp'),
      //   DeviceInfo("3", 3, 'Xiaomi Watch S3', 'watch.webp')
      // ], [
      //   DeviceInfo("0", 0, 'Xiaomi 14', 'phone.webp'),
      //   DeviceInfo("1", 1, 'RedmiBook Pro 15 锐龙版', 'pc.webp'),
      //   DeviceInfo("2", 2, 'Xiaomi Pad 14 Max', 'pad.webp'),
      //   DeviceInfo("3", 3, 'Xiaomi Watch S3', 'watch.webp')
      // ]
  );
}

class _DeviceScreenState extends State<DeviceScreen> {
  // var devices = <DeviceInfo>[];
  // var history = <DeviceInfo>[];

  // _DeviceScreenState(this.devices, this.history);

  @override
  Widget build(BuildContext context) {
    final deviceProvider = MultiCastClientProvider.of(context, listen: true);
    final devices = deviceProvider.deviceList.map((d) => d.toDeviceInfo()).toList();
    final history = <DeviceInfo>[];
    return Container(
      decoration:
          const BoxDecoration(color: Color.fromARGB(255, 247, 247, 247)),
      child: Stack(
        children: [
          SizedBox(
              width: double.infinity,
              child: Lottie.asset('assets/animations/radar.json',
                  fit: BoxFit.cover)),
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
                        // MultiCastClientProvider.of(context).clearDevices();
                        MultiCastClientProvider.of(context).startScan();
                      },
                      child: const Text('附近设备',
                          style: TextStyle(
                              color: Colors.black,
                              fontSize: 36.0,
                              fontWeight: FontWeight.normal)),
                    )),
                Expanded(
                    child: ListView(
                  children: [
                    ...List.generate(devices.length, (index) {
                      var deviceInfo = devices[index];
                      return GestureDetector(
                        onTap: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => ConcertScreen(
                                      deviceInfo: deviceInfo)));
                        },
                        child: Padding(
                          padding: const EdgeInsets.only(
                              bottom: 10, left: 16, right: 16),
                          child: DeviceItem(Key(devices[index].id), deviceInfo),
                        ),
                      );
                    }),
                     Padding(
                      padding: EdgeInsets.only(
                          left: 16, right: 16, top: 20, bottom: 6),
                      child: InkWell(
                        onTap:  (){
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
                    ...List.generate(history.length, (index) {
                      var historyItemInfo = history[index];
                      return HistoryItem(historyItemInfo: historyItemInfo);
                    })
                  ],
                ))
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class DeviceItem extends StatelessWidget {
  final DeviceInfo deviceInfo;

  const DeviceItem(Key key, this.deviceInfo) : super(key: key);

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
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Image(
                  image: AssetImage('assets/images/${deviceInfo.icon}'),
                  width: 36,
                  height: 36,
                  fit: BoxFit.fill,
                ),
                const SizedBox(
                  width: 10,
                ),
                Text(
                  deviceInfo.name,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                      color: Colors.black,
                      fontSize: 14,
                      fontWeight: FontWeight.w500),
                ),
              ],
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
