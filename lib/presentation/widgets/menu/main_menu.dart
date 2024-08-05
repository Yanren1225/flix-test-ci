import 'dart:io';

import 'package:flix/presentation/basic/corner/flix_decoration.dart';
import 'package:flix/presentation/screens/qrcode_scan_screen.dart';
import 'package:flix/presentation/screens/hotpots/hotspot_screen.dart';
import 'package:flix/presentation/screens/paircode/pair_code_screen.dart';
import 'package:flix/presentation/widgets/basic/animatable_pop_menu.dart';
import 'package:flix/presentation/widgets/menu/menu_item.dart';
import 'package:flix/theme/theme_extensions.dart';
import 'package:flutter/material.dart';
import 'package:modals/modals.dart';

void showMainMenu(BuildContext context, String tag) {
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
    child: MainMenu(navigator: Navigator.of(context)),
  ));
}

class MainMenu extends StatefulWidget {
  final NavigatorState navigator;

  const MainMenu({required this.navigator, super.key});


  @override
  State<StatefulWidget> createState() => MainMenuState();
}

class MainMenuState extends AnimatablePopMenuState<MainMenu> {
  @override
  Widget build(BuildContext context) {
    child ??= Material(
      color: Theme.of(context).flixColors.background.primary,
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
              MenuItem(
                lable: '扫一扫',
                icon: 'assets/images/ic_scan.svg',
                onTap: () {
                  removeAllModals();
                  widget.navigator.push(MaterialPageRoute(
                      builder: (context) =>
                          QrcodeScanScreen(showBack: true)));
                },
              ),
              Visibility(
                visible: Platform.isAndroid,
                child: Padding(
                  padding: const EdgeInsets.only(left: 16.0),
                  child: Container(
                    decoration: FlixDecoration(
                        color:
                            Theme.of(context).flixColors.background.tertiary),
                    height: 0.5,
                  ),
                ),
              ),
              Visibility(
                visible: Platform.isAndroid,
                child: MenuItem(
                  lable: '我的热点',
                  icon: 'assets/images/ic_qrcode.svg',
                  onTap: () {
                    removeAllModals();
                    widget.navigator.push(MaterialPageRoute(
                        builder: (context) => HotspotScreen(showBack: true)));
                  },
                ),
              ),
              MenuItem(
                lable: '添加设备',
                icon: 'assets/images/ic_add_device.svg',
                onTap: () {
                  removeAllModals();
                  widget.navigator.push(MaterialPageRoute(
                      builder: (context) => const PairCodeScreen()));
                },
              ),
            ],
          ),
        ),
      ),
    );
    return super.build(context);
  }
}