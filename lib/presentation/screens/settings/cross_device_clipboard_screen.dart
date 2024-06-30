import 'dart:collection';

import 'package:flix/domain/database/database.dart';
import 'package:flix/domain/device/device_manager.dart';
import 'package:flix/domain/device/device_profile_repo.dart';
import 'package:flix/domain/log/flix_log.dart';
import 'package:flix/domain/ship_server/ship_service_proxy.dart';
import 'package:flix/model/device_info.dart';
import 'package:flix/network/multicast_client_provider.dart';
import 'package:flix/presentation/widgets/bubble_context_menu/verification_code_bottom_sheet.dart';
import 'package:flix/presentation/widgets/devices/cross_device_item.dart';
import 'package:flix/presentation/widgets/devices/device_item.dart';
import 'package:flix/presentation/widgets/flix_toast.dart';
import 'package:flix/presentation/widgets/segements/navigation_scaffold.dart';
import 'package:flix/utils/compat/CompatUtil.dart';
import 'package:flix/utils/device/device_utils.dart';
import 'package:flix/utils/meida/media_utils.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

class CrossDeviceClipboardScreen extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return CrossDeviceClipboardScreenState();
  }
}

class CrossDeviceClipboardScreenState
    extends State<CrossDeviceClipboardScreen> {
  var pairSet = HashSet<String>();
  var pairCode = "";

  @override
  void initState() {
    super.initState();
    DeviceManager.instance.getAllPairDevice().then((value) {
      for (var element in value) {
        pairSet.add(element.fingerprint);
      }
      setState(() {});
    });
    DeviceProfileRepo.instance.getPairCode().then((value) {
      setState(() {
        pairCode = value;
      });
    });

    DeviceManager.instance.addPairDeviceChangeListener(_onPairDeviceChange);
  }

  @override
  void dispose() {
    super.dispose();
    DeviceManager.instance.removePairDeviceChangeListener(_onPairDeviceChange);
  }

  void _onPairDeviceChange(Set<PairDevice> value) {
    talker.debug('pairCode', 'addPairDeviceChangeListener = $value');
    pairSet.clear();
    for (var element in value) {
      pairSet.add(element.fingerprint);
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final deviceProvider = MultiCastClientProvider.of(context, listen: true);
    var devices =
        deviceProvider.deviceList.map((d) => d.toDeviceInfo()).toList();
    var pairDevices = devices.where((element) {
      return pairSet.contains(element.id);
    }).toList();
    var notPairDevice = devices.where((element) {
      return !pairSet.contains(element.id);
    }).toList();

    final appBar = AppBar(
        leading: GestureDetector(
      onTap: () {
        Navigator.pop(context);
      },
      child: const Icon(
        Icons.arrow_back_ios,
        color: Colors.black,
        size: 20,
      ),
    ));
    return Scaffold(
      appBar: appBar,
      body: buildRoot(context, pairDevices, devices, notPairDevice),
    );
  }

  Container buildRoot(BuildContext context, List<DeviceInfo> pairDevices,
      List<DeviceInfo> devices, List<DeviceInfo> notPairDevice) {
    return Container(
      margin: const EdgeInsets.only(left: 50, right: 50),
      height: double.infinity,
      child: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            SvgPicture.asset(
              'assets/images/ic_cross_device.svg',
              width: 40,
              height: 40,
              fit: BoxFit.cover,
            ),
            const SizedBox(height: 30),
            const Text(
              "跨设备复制粘贴",
              style: TextStyle(fontSize: 30),
            ),
            const SizedBox(height: 2),
            const Text(
              "关联设备后，复制的文字、图片可共享",
              style: TextStyle(
                  fontSize: 16, color: Color.fromARGB(255, 60, 60, 67)),
            ),
            const SizedBox(height: 30),
            creteButton(
                context, "assets/images/ic_cross_device_share.svg", "查看本机关联码"),
            Visibility(
                visible: pairDevices.isNotEmpty,
                child: const SizedBox(height: 20)),
            Visibility(
                visible: pairDevices.isNotEmpty,
                child: const SizedBox(
                  width: double.infinity,
                  child: Text(
                    "已关联的设备",
                    style: TextStyle(color: Color(0x993C3C43)),
                  ),
                ))
            // ... 放置多个 Widget
            ,
            Visibility(
                visible: pairDevices.isNotEmpty,
                child: const SizedBox(height: 20)),
            ListView.builder(
              itemBuilder: (BuildContext context, int index) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: CrossDeviceItem(
                      ValueKey(pairDevices[index].id), pairDevices[index], true,
                      () async {
                        shipService.deletePairDevice(pairDevices[index].id);
                    setState(() {});
                  }),
                );
              },
              itemCount: pairDevices.length,
              shrinkWrap: true,
            ),
            const Visibility(visible: true, child: SizedBox(height: 20)),
            Visibility(
                visible: notPairDevice.isNotEmpty,
                child: const SizedBox(
                  width: double.infinity,
                  child: Text(
                    "当前网络下的其他可用设备：",
                    style: TextStyle(color: Color(0x993C3C43)),
                  ),
                )),
            const SizedBox(height: 8),
            ListView.builder(
              itemBuilder: (BuildContext context, int index) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: CrossDeviceItem(ValueKey(notPairDevice[index].id),
                      notPairDevice[index], false, () {
                    talker.debug(
                        'pairDevice', 'click start = ${notPairDevice[index]}');
                    if (!CompatUtil.supportPairDevice(notPairDevice[index])) {
                      FlixToast.withContext(context).info("目标设备版本过低，不支持配对");
                      return;
                    }
                    showCupertinoModalPopup(
                        context: context,
                        builder: (context) => CrossDeviceShowCodeBottomSheet(
                              onConfirm: (code) {
                                if (code.isNotEmpty && code.length == 4) {
                                  shipService.askPairDevice(
                                      notPairDevice[index].id, code);
                                }
                              },
                              isEdit: true,
                            ));
                  }),
                );
              },
              itemCount: notPairDevice.length,
              shrinkWrap: true,
            ),
          ],
        ),
      ),
    );
  }

  Widget creteButton(BuildContext context, String icon, String text) {
    return InkWell(
        onTap: () {
          showCupertinoModalPopup(
              context: context,
              builder: (context) => CrossDeviceShowCodeBottomSheet(
                    isEdit: false,
                    code: pairCode,
                  ));
        },
        child: Container(
            height: 54,
            decoration: const BoxDecoration(
              color: true
                  ? Color.fromARGB(255, 0, 122, 255)
                  : Colors.transparent, // 设置背景颜色
              borderRadius: BorderRadius.all(Radius.circular(14)), // 设置圆角
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                // 使用 Image.asset 来加载图片，或者你可以使用 Image.network 来加载网络图片
                SvgPicture.asset(
                  icon,
                  width: 24,
                  height: 24,
                ),
                const SizedBox(width: 8), // 添加一些间距
                Text(text, style: const TextStyle(color: Colors.white)), // 按钮文本
              ],
            )));
  }
}
