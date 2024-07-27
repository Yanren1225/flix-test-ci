import 'package:flix/domain/hotspot/hotspot_manager.dart';
import 'package:flix/presentation/basic/corner/flix_decoration.dart';
import 'package:flix/presentation/style/colors/flix_color.dart';
import 'package:flix/presentation/style/flix_text_style.dart';
import 'package:flix/presentation/widgets/flix_bottom_sheet.dart';
import 'package:flix/presentation/widgets/flix_toast.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

showNetInfoBottomSheet(
    BuildContext context, String apName, String wifiName) async {
  await showCupertinoModalPopup(
      context: context,
      builder: (context) {
        return NetInfoBottomSheet(
          apName: apName,
          wifiName: wifiName,
        );
      });
}

class NetInfoBottomSheet extends StatelessWidget {
  final String apName;
  final String wifiName;

  const NetInfoBottomSheet(
      {Key? key, required this.apName, required this.wifiName})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FlixBottomSheet(
      title: "网络连接信息",
      child: Padding(
          padding: const EdgeInsets.only(top: 24, bottom: 28),
          child: NetInfoList(
            apName: apName,
            wifiName: wifiName,
          )),
    );
  }
}

class NetInfoList extends StatefulWidget {
  final String apName;
  final String wifiName;

  const NetInfoList({super.key, required this.apName, required this.wifiName});

  @override
  State<StatefulWidget> createState() {
    return _NetInfoListState();
  }
}

class _NetInfoListState extends State<NetInfoList> {
  @override
  Widget build(BuildContext context) {
    List<Widget> list = [];
    if (widget.apName.isNotEmpty) {
      list.add(NetInfoListTile(
        icon: 'assets/images/ic_ap.svg',
        label: widget.apName,
        action: "关闭",
        onTap: () async {
          if (await hotspotManager.disableHotspot()) {
            hotspotManager.getHotspotInfo();
            FlixToast.withContext(context).info("热点已关闭");
            Navigator.of(context).pop();
          }
        },
      ));
    }

    if (widget.wifiName.isNotEmpty) {
      list.add(NetInfoListTile(
        icon: 'assets/images/ic_wifi.svg',
        label: widget.wifiName,
      ));
    }
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: list,
    );
  }
}

class NetInfoListTile extends StatelessWidget {
  final String icon;
  final String label;
  final String? action;
  final VoidCallback? onTap;

  const NetInfoListTile(
      {Key? key,
      required this.icon,
      required this.label,
      this.action,
      this.onTap})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Flexible(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                SvgPicture.asset(
                  icon,
                  width: 20,
                  height: 20,
                  colorFilter:
                      const ColorFilter.mode(FlixColor.blue, BlendMode.srcIn),
                ),
                const SizedBox(
                  width: 4,
                ),
                Flexible(
                  child: Text(
                    label,
                    style: context.title(),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
          Visibility(
              visible: action != null,
              child: InkWell(
                  onTap: onTap,
                  child: Container(
                      height: 26,
                      decoration: FlixDecoration(
                          color: FlixColor.red,
                          borderRadius:
                              const BorderRadius.all(Radius.circular(13))),
                      child: Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16),
                          child: Center(
                            child: Text(
                              action ?? "",
                              style: context.onButton(),
                            ),
                          ))))),
        ],
      ),
    );
  }
}
