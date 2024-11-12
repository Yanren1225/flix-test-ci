import 'dart:io';

import 'package:flix/domain/device/device_profile_repo.dart';
import 'package:flix/domain/log/flix_log.dart';
import 'package:flix/domain/ship_server/ship_service_proxy.dart';
import 'package:flix/l10n/lang_config.dart';
import 'package:flix/utils/platform_utils.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter95/flutter95.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../domain/device/device_manager.dart';
import '../../../../l10n/l10n.dart';
import '../../../../main.dart';
import '../../intro_screen.dart';

class ClientInfoPage extends StatefulWidget {

  final void Function(BuildContext)? onClosePressed;

  const ClientInfoPage({
    Key? key,
    this.onClosePressed,
  }) : super(key: key);

  @override
  State<ClientInfoPage> createState() {
    return ClientInfoPageState();
  }
}

class ClientInfoPageState extends State<ClientInfoPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold95(
      title: '客户端信息',
      onClosePressed: widget.onClosePressed,
      toolbar: Toolbar95(actions: [
        Item95(
            label: "ShipServerProxy",
            menu: Menu95(
                items: [
                  MenuItem95(
                    value: 0,
                    label: "Start",
                  ),
                  MenuItem95(
                    value: 1,
                    label: "Restart",
                  ),
                ],
                onItemSelected: (index) {
                  switch (index) {
                    case 0:
                      shipService.startShipServer();
                      break;
                    case 1:
                      shipService.restartShipServer();
                      break;
                  }
                })),
        Item95(
            label: "欢迎页",
            menu: Menu95(
              items: [
                MenuItem95(
                  value: 0,
                  label: "重置 isFirstRun",
                ),
                MenuItem95(
                  value: 1,
                  label: "显示欢迎页",
                ),
              ],
              onItemSelected: (index) {
                switch (index) {
                  case 0:
                    Future<SharedPreferences> prefs =
                        SharedPreferences.getInstance();
                    prefs.then((value) {
                      value.setBool("isFirstRun", true);
                    });
                    break;
                  case 1:
                    Navigator.push(
                        context,
                        CupertinoPageRoute(
                          builder: (context) => IntroPage(),
                        ));
                    break;
                }
              },
            )),
        Item95(
          label: "语言",
          menu: Menu95(
              items: [
                for (var index = 0;
                    index < S.delegate.supportedLocales.length;
                    index++)
                  MenuItem95(
                    value: index,
                    label: S.delegate.supportedLocales[index].toString(),
                  )
              ],
              onItemSelected: (index) async {
                LangConfig.instance.setLang(S.delegate.supportedLocales[index]);
              }),
        )
      ]),
      body: Expanded(
        child: Elevation95(
          type: Elevation95Type.down,
          child: Padding(
            padding: const EdgeInsets.all(8),
            child: ListView(
              children: [
                dumpProfileRepo(),
                FutureBuilder<Widget>(
                  future: dumpDeviceModal(),
                  builder: (context, snapshot) {
                    if (snapshot.hasData) {
                      return snapshot.data!;
                    } else {
                      return infoBox("Device Modal", "加载失败");
                    }
                  },
                ),
                FutureBuilder<Widget>(
                  future: dumpPackageInfo(),
                  builder: (context, snapshot) {
                    if (snapshot.hasData) {
                      return snapshot.data!;
                    } else {
                      return infoBox("Package Info", "加载失败");
                    }
                  },
                ),
                FutureBuilder<Widget>(
                  future: dumpNetworkInfo(),
                  builder: (context, snapshot) {
                    if (snapshot.hasData) {
                      return snapshot.data!;
                    } else {
                      return infoBox("Network Info", "加载失败");
                    }
                  },
                ),
                FutureBuilder<Widget>(
                  future: dumpDevices(),
                  builder: (context, snapshot) {
                    if (snapshot.hasData) {
                      return snapshot.data!;
                    } else {
                      return infoBox("Devices", "加载失败");
                    }
                  },
                ),
                FutureBuilder<Widget>(
                  future: dumpDeviceHistory(),
                  builder: (context, snapshot) {
                    if (snapshot.hasData) {
                      return snapshot.data!;
                    } else {
                      return infoBox("Device History", "加载失败");
                    }
                  },
                ),
                FutureBuilder<Widget>(
                  future: dumpPairDevices(),
                  builder: (context, snapshot) {
                    if (snapshot.hasData) {
                      return snapshot.data!;
                    } else {
                      return infoBox("Pair Devices", "加载失败");
                    }
                  },
                ),
                FutureBuilder<Widget>(
                  future: dumpPlatformInfo(),
                  builder: (context, snapshot) {
                    if (snapshot.hasData) {
                      return snapshot.data!;
                    } else {
                      return infoBox("Platform Info", "加载失败");
                    }
                  },
                ),
                FutureBuilder<Widget>(
                  future: dumpDeviceInfo(),
                  builder: (context, snapshot) {
                    if (snapshot.hasData) {
                      return snapshot.data!;
                    } else {
                      return infoBox("Device Info", "加载失败");
                    }
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

Widget text95(String text) {
  return Text(
    text,
    style: Flutter95.textStyle,
  );
}

Widget infoBox(String title, String content) {
  return Container(
    padding: const EdgeInsets.all(8),
    width: double.infinity,
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        text95(title),
        Padding(
          padding: const EdgeInsets.only(top: 8),
          child: Elevation95(
              type: Elevation95Type.down,
              child: Padding(
                  padding: const EdgeInsets.all(8),
                  child: SizedBox(
                    width: double.infinity,
                    child: text95(content),
                  ))),
        ),
      ],
    ),
  );
}

String joinList(List<String> list) {
  return list.join("\n");
}

Widget dumpProfileRepo() {
  return infoBox(
      "Device Profile Repo",
      joinList([
        "did: ${DeviceProfileRepo.instance.did}",
        "deviceName: ${DeviceProfileRepo.instance.deviceName}",
      ]));
}

Future<Widget> dumpPlatformInfo() async {
  var _isMobile = isMobile();
  var _isDesktop = isDesktop();
  var os = Platform.operatingSystem;
  var version = Platform.operatingSystemVersion;
  var locale = Platform.localeName;
  return infoBox(
      "Platform Info",
      joinList([
        "isMobile: $_isMobile",
        "isDesktop: $_isDesktop",
        "os: $os",
        "version: $version",
        "locale: $locale",
      ]));
}

Future<Widget> dumpPackageInfo() async {
  var packageInfo = await PackageInfo.fromPlatform();
  return infoBox(
      "Package Info",
      joinList([
        "appName: ${packageInfo.appName}",
        "packageName: ${packageInfo.packageName}",
        "version: ${packageInfo.version}",
        "buildNumber: ${packageInfo.buildNumber}",
        "buildSignature: ${packageInfo.buildSignature}",
        "installerStore: ${packageInfo.installerStore}",
      ]));
}

Future<Widget> dumpDeviceInfo() async {
  var deviceInfo = await DeviceProfileRepo.instance.getDeviceInfo();
  return infoBox(
      "Device Info",
      joinList([
        "alias: ${deviceInfo.alias}",
        "deviceType: ${deviceInfo.deviceType}",
        "deviceModel: ${deviceInfo.deviceModel}",
        "androidSdkInt: ${deviceInfo.androidSdkInt}",
      ]));
}

Future<Widget> dumpDeviceModal() async {
  var port = await shipService.getPort();
  var deviceModal = await DeviceProfileRepo.instance.getDeviceModal(port);
  return infoBox(
      "Device Modal",
      joinList([
        "alias: ${deviceModal.alias}",
        "deviceType: ${deviceModal.deviceType}",
        "fingerprint: ${deviceModal.fingerprint}",
        "port: ${deviceModal.port}",
        "version: ${deviceModal.version}",
        "deviceModel: ${deviceModal.deviceModel}",
      ]));
}

Future<Widget> dumpNetworkInfo() async {
  var networkInfo = await await NetworkInterface.list(
      includeLoopback: false,
      includeLinkLocal: false,
      type: InternetAddressType.IPv4);
  return infoBox(
      "Network Info",
      joinList([
        for (var info in networkInfo)
          "name: ${info.name}, address: ${[
            for (var address in info.addresses)
              '${address.address}(host=${address.host})'
          ].join(", ")}",
      ]));
}

Future<Widget> dumpDevices() async {
  final devices = DeviceManager.instance.deviceList;
  return infoBox(
      "Devices",
      joinList([
        for (var device in devices)
          "alias: ${device.alias}, deviceModel: ${device.deviceModel}, deviceType: ${device.deviceType}, fingerprint: ${device.fingerprint}, version: ${device.version}, port: ${device.port}, ip: ${device.ip}, host: ${device.host}, from: ${device.from}\n",
      ]));
}

Future<Widget> dumpDeviceHistory() async {
  var deviceInfo = DeviceManager.instance.history;
  return infoBox(
      "Device History",
      joinList([
        for (var device in deviceInfo)
          "alias: ${device.alias}, deviceModel: ${device.deviceModel}, deviceType: ${device.deviceType}, fingerprint: ${device.fingerprint}, version: ${device.version}, port: ${device.port}, ip: ${device.ip}, host: ${device.host}, from: ${device.from}\n",
      ]));
}

Future<Widget> dumpPairDevices() async {
  var pairDevices = DeviceManager.instance.pairDevices;
  return infoBox(
      "Pair Devices",
      joinList([
        for (var device in pairDevices)
          "code: ${device.code}, fingerprint: ${device.fingerprint}, insertOrUpdateTime: ${device.insertOrUpdateTime}\n",
      ]));
}
