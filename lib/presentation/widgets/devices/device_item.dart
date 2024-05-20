import 'package:flix/utils/text/text_extension.dart';
import 'package:flix/model/device_info.dart';
import 'package:flix/presentation/screens/concert/droper.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

typedef OnTap = bool Function();

class DeviceItem extends StatefulWidget {
  final DeviceInfo deviceInfo;
  final int badge;
  final VoidCallback onTap;
  final bool selected;

  DeviceItem(Key key, this.deviceInfo, this.onTap,
      {this.selected = false, this.badge = 0})
      : super(key: key);

  @override
  DeviceItemState createState() => DeviceItemState();


}

class DeviceItemState extends State<DeviceItem> {

  DeviceInfo get deviceInfo => widget.deviceInfo;

  int get badge => widget.badge;

  VoidCallback get onTap => widget.onTap;

  bool get selected => widget.selected;
  bool droping = false;


  @override
  Widget build(BuildContext context) {
    return Droper(
      deviceInfo: deviceInfo,
      onDropEntered: () {
        setState(() {
          droping = true;
        });
      },
      onDropExited: () {
        setState(() {
          droping = false;
        });
      },
      child: Material(
          color: droping ? const Color.fromRGBO(204, 204, 204, 0.1) : Colors.white,
      borderRadius:
      selected ? null : const BorderRadius.all(Radius.circular(20)),
      clipBehavior: Clip.antiAlias,
      shape: selected
          ? RoundedRectangleBorder(
          side: const BorderSide(
            color: const Color.fromRGBO(0, 122, 255, 1),
            width: 2,
          ),
          borderRadius: BorderRadius.circular(20))
          : null,
      child: InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Flexible(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      badge > 0
                          ? Badge(
                        backgroundColor: Colors.red,
                        textColor: Colors.white,
                        label: badge > 9
                            ? const Padding(
                            padding:
                            EdgeInsets.symmetric(horizontal: 4),
                            child: const Text('9+'))
                            : SizedBox(
                            width: 16,
                            height: 16,
                            child: Center(child: Text('$badge'))),
                        padding: EdgeInsets.zero,
                        child: Image(
                          image: AssetImage(
                              'assets/images/${deviceInfo.icon}'),
                          width: 36,
                          height: 36,
                          fit: BoxFit.fill,
                        ),
                      )
                          : Image(
                        image: AssetImage(
                            'assets/images/${deviceInfo.icon}'),
                        width: 36,
                        height: 36,
                        fit: BoxFit.fill,
                      ),
                      const SizedBox(
                        width: 10,
                      ),
                      Flexible(
                        child: Text(
                          deviceInfo.name,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                              color: Colors.black,
                              fontSize: 14,
                              fontWeight: FontWeight.w500).fix(),
                        ),
                      ),
                    ],
                  ),
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
          )),
    ),);
  }
}
