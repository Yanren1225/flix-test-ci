import 'dart:collection';

import 'package:flix/presentation/style/colors/flix_color.dart';
import 'package:flix/theme/theme_extensions.dart';
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
import 'package:flix/utils/compat/compat_util.dart';
import 'package:flix/utils/device/device_utils.dart';
import 'package:flix/utils/meida/media_utils.dart';
import 'package:flix/utils/text/text_extension.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

import '../../../l10n/l10n.dart';

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

    //TODO: 这里或许需要更优雅的处理方式, 以处理这个不是一直都需要出现的返回键
    final appBar = AppBar(
      leading: GestureDetector(
        onTap: () {
          if (Navigator.canPop(context)) {
            Navigator.pop(context);
          }
        },
        child: Icon(
          Icons.arrow_back_ios,
          color: Theme.of(context).flixColors.text.primary,
          size: Navigator.canPop(context) ? 20 : 0,
        ),
      ),
      backgroundColor: Theme.of(context).flixColors.background.secondary,
    );
    return Scaffold(
      appBar: appBar,
      body: buildRoot(context, pairDevices, devices, notPairDevice),
      backgroundColor: Theme.of(context).flixColors.background.secondary,
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
              colorFilter: ColorFilter.mode(
                  Theme.of(context).flixColors.text.primary, BlendMode.srcIn),
            ),
            const SizedBox(height: 30),
            Text(
              S.of(context).setting_cross_device_clipboard,
              style: const TextStyle(fontSize: 30).fix(),
            ),
            const SizedBox(height: 2),
            Text(
              S.of(context).setting_cross_device_clipboard_tip,
              style: TextStyle(
                      fontSize: 16,
                      color: Theme.of(context).flixColors.text.secondary)
                  .fix(),
            ),
            const SizedBox(height: 30),
            creteButton(
                context, "assets/images/ic_cross_device_share.svg", S.of(context).setting_cross_device_clipboard_paircode),
            Visibility(
                visible: pairDevices.isNotEmpty,
                child: const SizedBox(height: 20)),
            Visibility(
                visible: pairDevices.isNotEmpty,
                child: SizedBox(
                  width: double.infinity,
                  child: Text(
                    S.of(context).setting_cross_device_clipboard_paired_devices,
                    style: TextStyle(
                        color: Theme.of(context).flixColors.text.secondary),
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
                child: SizedBox(
                  width: double.infinity,
                  child: Text(
                    S.of(context).setting_cross_device_clipboard_other_devices,
                    style: TextStyle(
                        color: Theme.of(context).flixColors.text.secondary),
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
                      FlixToast.withContext(context).info(S.of(context).setting_cross_device_clipboard_too_low_to_pair);
                      return;
                    }
                    showCupertinoModalPopup(
                        context: context,
                        builder: (context) => CrossDeviceShowCodeBottomSheet(
                              title: S.of(context).setting_cross_device_clipboard_popup_input_paircode,
                              subtitle: S.of(context).setting_cross_device_clipboard_popup_input_paircode_subtitle,
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
                    title: S.of(context).setting_cross_device_clipboard_popup_self_paircode,
                    subtitle: S.of(context).setting_cross_device_clipboard_popup_self_paircode_subtitle,
                    isEdit: false,
                    code: pairCode,
                  ));
        },
        child: Container(
            height: 54,
            decoration: const BoxDecoration(
              color: true ? FlixColor.blue : Colors.transparent, // 设置背景颜色
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
