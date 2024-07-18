import 'dart:io';

import 'package:flix/presentation/basic/corner/flix_decoration.dart';
import 'package:flix/presentation/screens/hotpots/hotpots_scanner_screen.dart';
import 'package:flix/presentation/screens/hotpots/hotspot_screen.dart';
import 'package:flix/presentation/widgets/basic/animatable_pop_menu.dart';
import 'package:flix/presentation/widgets/menu/device_pair_menu_item.dart';
import 'package:flutter/material.dart';
import 'package:modals/modals.dart';

void showDevicePairMenu(BuildContext context, String tag) {
  showModal(ModalEntry.anchored(
    context,
    tag: 'device_pair_menu',
    anchorTag: tag,
    modalAlignment: Alignment.topRight,
    anchorAlignment: Alignment.bottomRight,
    offset: const Offset(0, 12),
    barrierColor: const Color.fromRGBO(0, 0, 0, 0.45),
    removeOnPop: true,
    barrierDismissible: true,
    child: DevicePairMenu(navigator: Navigator.of(context)),
  ));
}

class DevicePairMenu extends StatefulWidget {
  final NavigatorState navigator;

  const DevicePairMenu({required this.navigator, super.key});


  @override
  State<StatefulWidget> createState() => DevicePairMenuState();
}

class DevicePairMenuState extends AnimatablePopMenuState<DevicePairMenu> {
  @override
  void initState() {
    super.initState();
    child = Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(14),
      child: SizedBox(
        width: 170,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 6),
          child: Column(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              DevicePairMenuItem(
                lable: '扫一扫',
                icon: 'assets/images/ic_scan.svg',
                onTap: () {
                  removeAllModals();
                  widget.navigator.push(MaterialPageRoute(builder: (context) => HotpotsScannerScreen(showBack: true)));
                },
              ),
              Visibility(
                visible: Platform.isAndroid,
                child: Padding(
                  padding: const EdgeInsets.only(left: 16.0),
                  child: Container(
                    decoration: FlixDecoration(color: const Color.fromRGBO(242, 242, 242, 1)),
                    height: 0.5,
                  ),
                ),
              ),
              Visibility(
                visible: Platform.isAndroid,
                child: DevicePairMenuItem(
                  lable: '我的二维码',
                  icon: 'assets/images/ic_qrcode.svg',
                  onTap:() {
                    removeAllModals();
                    widget.navigator.push(MaterialPageRoute(builder: (context) => HotspotScreen(showBack: true)));
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}