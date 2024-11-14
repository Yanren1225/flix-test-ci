import 'dart:io';

import 'package:easy_refresh/easy_refresh.dart';
import 'package:flix/domain/device/device_discover.dart';
import 'package:flix/domain/device/device_profile_repo.dart';
import 'package:flix/domain/log/flix_log.dart';
import 'package:flix/domain/ship_server/ship_service_proxy.dart';
import 'package:flix/l10n/lang_config.dart';
import 'package:flix/network/protocol/device_modal.dart';
import 'package:flix/utils/device_info_helper.dart';
import 'package:flix/utils/platform_utils.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter95/flutter95.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../domain/database/database.dart';
import '../../../../domain/device/device_manager.dart';
import '../../../../l10n/l10n.dart';
import '../../../../main.dart';
import '../../../../network/multicast_client_provider.dart';
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
  final EasyRefreshController _controller = EasyRefreshController();

  List<DeviceModal> deviceList = [];
  List<DeviceModal> history = [];
  List<PairDevice> pairDevices = [];

  PackageInfo? packageInfo;
  DeviceInfoResult? deviceInfo;

  int? port;
  DeviceModal? deviceModal;

  List<NetworkInterface> networkInfo = [];

  bool showLocalhost = false;

  void _onDeviceListChangedD(Set<DeviceModal> devices) {
    setState(() {
      deviceList = devices.toList();
    });
  }

  void _onHistoryChangedD(Set<DeviceModal> devices) {
    setState(() {
      history = devices.toList();
    });
  }

  void _onPairDeviceChangedD(Set<PairDevice> devices) {
    setState(() {
      pairDevices = devices.toList();
    });
  }

  @override
  void initState() {
    super.initState();
    DeviceManager.instance.addDeviceListChangeListener(_onDeviceListChangedD);
    DeviceManager.instance.addHistoryChangeListener(_onHistoryChangedD);
    DeviceManager.instance.addPairDeviceChangeListener(_onPairDeviceChangedD);
    initAsync();
  }

  void initAsync() async {
    port = await shipService.getPort();
    PackageInfo.fromPlatform().then((PackageInfo info) {
      setState(() {
        packageInfo = info;
      });
    });
    DeviceProfileRepo.instance
        .getDeviceInfo()
        .then((DeviceInfoResult deviceInfo2) {
      setState(() {
        deviceInfo = deviceInfo2;
      });
    });
    DeviceProfileRepo.instance
        .getDeviceInfo()
        .then((DeviceInfoResult deviceProfile) {
      setState(() {
        deviceProfile = deviceProfile;
      });
    });
    DeviceProfileRepo.instance.getDeviceModal(port!).then((DeviceModal modal) {
      setState(() {
        deviceModal = modal;
      });
    });
    NetworkInterface.list(
            includeLoopback: false,
            includeLinkLocal: false,
            type: InternetAddressType.IPv4)
        .then((List<NetworkInterface> data) {
      setState(() {
        networkInfo = data;
      });
    });
  }

  @override
  void dispose() {
    super.dispose();
    DeviceManager.instance
        .removeDeviceListChangeListener(_onDeviceListChangedD);
    DeviceManager.instance.removeHistoryChangeListener(_onHistoryChangedD);
    DeviceManager.instance
        .removePairDeviceChangeListener(_onPairDeviceChangedD);
  }

  @override
  Widget build(BuildContext context) {
    var _isMobile = isMobile();
    var _isDesktop = isDesktop();
    var os = Platform.operatingSystem;
    var version = Platform.operatingSystemVersion;
    var locale = Platform.localeName;

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
            child: EasyRefresh(
              controller: _controller,
              onRefresh: () {
                initAsync();
              },
              child: ListView(
                children: [
                  infoBox(
                      "Device Profile Repo",
                      joinList([
                        "did: ${DeviceProfileRepo.instance.did}",
                        "deviceName: ${DeviceProfileRepo.instance.deviceName}",
                      ])),
                  infoBox(
                      "Platform Info",
                      joinList([
                        "isMobile: $_isMobile",
                        "isDesktop: $_isDesktop",
                        "os: $os",
                        "version: $version",
                        "locale: $locale",
                      ])),
                  infoBox(
                      "Package Info",
                      joinList([
                        "appName: ${packageInfo?.appName}",
                        "packageName: ${packageInfo?.packageName}",
                        "version: ${packageInfo?.version}",
                        "buildNumber: ${packageInfo?.buildNumber}",
                        "buildSignature: ${packageInfo?.buildSignature}",
                        "installerStore: ${packageInfo?.installerStore}",
                      ])),
                  infoBox(
                      "Network Info",
                      joinList([
                        for (var info in networkInfo)
                          "name: ${info.name}, address: ${[
                            for (var address in info.addresses)
                              '${address.address}(host=${address.host})'
                          ].join(", ")}",
                      ])),
                  infoBox(
                      "Devices",
                      joinList([
                        for (var device in deviceList)
                          "alias: ${device.alias}, deviceModel: ${device.deviceModel}, deviceType: ${device.deviceType}, fingerprint: ${device.fingerprint}, version: ${device.version}, port: ${device.port}, ip: ${device.ip}, host: ${device.host}, from: ${device.from}\n",
                      ])),
                  Container(
                    padding: const EdgeInsets.all(8),
                    width: double.infinity,
                    child: Row(
                      children: [
                        Checkbox95(
                          value: showLocalhost,
                          onChanged: (value) {
                            setState(() {
                              showLocalhost = value;
                            });
                            generateLocalhostDevice()
                                .then((DeviceModal localhost) {
                              if (value == true) {
                                DeviceManager.instance.addDevice(localhost);
                              } else {
                                DeviceManager.instance.deleteDevice(localhost);
                                MultiCastClientProvider.of(context,
                                        listen: false)
                                    .deleteHistory(localhost.fingerprint);
                              }
                            });
                          },
                        ),
                        const Padding(padding: EdgeInsets.only(right: 2)),
                        text95("显示 localhost"),
                        const Padding(padding: EdgeInsets.only(right: 8)),
                        Button95(
                          child: const Text("显示"),
                          onTap: () async {
                            var localhost = await generateLocalhostDevice();
                            DeviceManager.instance.addDevice(localhost);
                            setState(() {
                              showLocalhost = true;
                            });
                          },
                        ),
                        const Padding(padding: EdgeInsets.only(right: 8)),
                        Button95(
                          child: const Text("删除"),
                          onTap: () async {
                            var localhost = await generateLocalhostDevice();
                            DeviceManager.instance.deleteDevice(localhost);
                            MultiCastClientProvider.of(context, listen: false)
                                .deleteHistory(localhost.fingerprint);
                            setState(() {
                              showLocalhost = false;
                            });
                          },
                        ),
                      ],
                    ),
                  ),
                  infoBox(
                      "Device History",
                      joinList([
                        for (var device in history)
                          "alias: ${device.alias}, deviceModel: ${device.deviceModel}, deviceType: ${device.deviceType}, fingerprint: ${device.fingerprint}, version: ${device.version}, port: ${device.port}, ip: ${device.ip}, host: ${device.host}, from: ${device.from}\n",
                      ])),
                  infoBox(
                      "Pair Devices",
                      joinList([
                        for (var device in pairDevices)
                          "code: ${device.code}, fingerprint: ${device.fingerprint}, insertOrUpdateTime: ${device.insertOrUpdateTime}\n",
                      ])),
                  infoBox(
                      "Platform Info",
                      joinList([
                        "isMobile: $_isMobile",
                        "isDesktop: $_isDesktop",
                        "os: $os",
                        "version: $version",
                        "locale: $locale",
                      ])),
                  infoBox(
                      "Device Info",
                      joinList([
                        "alias: ${deviceInfo?.alias}",
                        "deviceType: ${deviceInfo?.deviceType}",
                        "deviceModel: ${deviceInfo?.deviceModel}",
                        "androidSdkInt: ${deviceInfo?.androidSdkInt}",
                      ])),
                ],
              ),
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

Future<DeviceModal> generateLocalhostDevice() async {
  return DeviceModal(
    alias: "Localhost[DebugOnly]",
    deviceModel: "Localhost[DebugOnly]",
    deviceType: await DeviceProfileRepo.instance
        .getDeviceInfo()
        .then((value) => value.deviceType),
    fingerprint: "00000000-0000-0000-0000-000000000000",
    version: int.parse(
        await PackageInfo.fromPlatform().then((value) => value.buildNumber)),
    port: await shipService.getPort(),
    ip: "127.0.0.1",
  );
}
