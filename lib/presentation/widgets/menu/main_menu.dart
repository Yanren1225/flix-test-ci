import 'dart:io';

import 'package:flix/presentation/basic/corner/flix_decoration.dart';
import 'package:flix/presentation/screens/qrcode_scan_screen.dart';
import 'package:flix/presentation/screens/hotpots/hotspot_screen.dart';
import 'package:flix/presentation/screens/paircode/pair_code_screen.dart';
import 'package:flix/presentation/widgets/basic/animatable_pop_menu.dart';
import 'package:flix/presentation/widgets/menu/menu_item.dart';
import 'package:flix/theme/theme_extensions.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:modals/modals.dart';

import '../../../l10n/l10n.dart';
import '../../../utils/platform_utils.dart';
import '../../screens/paircode/add_device_screen.dart';

void showMainMenu(BuildContext context, String tag,
    void Function()? onViewConnectInfo, void Function()? onGoManualAdd, void Function()? onWebInfo) {
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
    child: MainMenu(
        navigator: Navigator.of(context),
        onViewConnectInfo: onViewConnectInfo ?? () {},
        onGoManualAdd: onGoManualAdd ?? () {}, 
        onWebInfo: onWebInfo ?? () {}, ),
  ));
}

class MainMenu extends StatefulWidget {
  final NavigatorState navigator;
  final void Function() onViewConnectInfo;
  final void Function() onGoManualAdd;
  final void Function() onWebInfo;

  const MainMenu(
      {required this.navigator,
      super.key,
      required this.onViewConnectInfo,
      required this.onGoManualAdd,
      required this.onWebInfo});

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
              Visibility(
                visible: isMobile(),
                child: MenuItem(
                  lable: S.of(context).menu_scan,
                  icon: 'assets/images/ic_scan.svg',
                  onTap: () {
                    removeAllModals();
                    widget.navigator.push(MaterialPageRoute(
                        builder: (context) =>
                            QrcodeScanScreen(showBack: true)));
                  },
                ),
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
                  lable: S.of(context).menu_hotspot,
                  icon: 'assets/images/ic_qrcode.svg',
                  onTap: () {
                    removeAllModals();
                    widget.navigator.push(MaterialPageRoute(
                        builder: (context) => HotspotScreen(showBack: true)));
                  },
                ),
              ),
              MenuItem(
                lable: isMobile()
                    ? S.of(context).menu_add_manually
                    : S.of(context).menu_add_this_device,
                icon: isMobile()
                    ? 'assets/images/ic_manul_add.svg'
                    : 'assets/images/ic_qrcode.svg',
                onTap: () {
                  /*
                  removeAllModals();
                  widget.navigator.push(CupertinoPageRoute(
                      builder: (context) => const PairCodeScreen()));

                   */
                  removeAllModals();
                  widget.onViewConnectInfo();
                },
              ),
              Visibility(
                  visible: isDesktop(),
                  child: MenuItem(
                    lable: S.of(context).menu_add_manually_input,
                    icon: 'assets/images/ic_manul_add.svg',
                    onTap: () {
                      /*
                  widget.navigator.push(CupertinoPageRoute(
                      builder: (context) => const AddDeviceScreen()));
                   */
                      removeAllModals();
                      widget.onGoManualAdd();
                    },
                  )),
                Visibility(
                  visible: true,
                  child: MenuItem(
                    lable: '连接网页版',
                    icon: 'assets/images/web.svg',
                    onTap: () {
                      /*
                  widget.navigator.push(CupertinoPageRoute(
                      builder: (context) => const AddDeviceScreen()));
                   */
                      removeAllModals();
                      widget.onWebInfo();
                    },
                  ))
            ],
          ),
        ),
      ),
    );
    return super.build(context);
  }
}
