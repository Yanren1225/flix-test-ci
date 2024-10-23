import 'dart:io';

import 'package:figma_squircle/figma_squircle.dart';
import 'package:flix/theme/theme_extensions.dart';
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

  const DeviceItem(Key key, this.deviceInfo, this.onTap,
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
      child: InkWell(
        onTap: onTap,
        child: SizedBox(
        child: DecoratedBox(
         decoration: ShapeDecoration(
        shadows: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            offset: const Offset(0, 4),
            blurRadius: 6,
          ),
        ],
        color: Theme.of(context).brightness == Brightness.dark
            ? (selected
                ? const Color.fromRGBO(28, 28, 30, 1)
                : Theme.of(context).flixColors.background.primary)
            : (selected
                ? const Color.fromRGBO(232, 243, 255, 1)
                : Theme.of(context).flixColors.background.primary),
        shape: SmoothRectangleBorder(
          borderRadius: SmoothBorderRadius(
            cornerRadius: 15, 
            cornerSmoothing: 0.6, 
          ),
          side: selected
              ? const BorderSide(
                  color: Color.fromRGBO(0, 122, 255, 1),
                  width: 1.4,
                )
              : BorderSide.none,
        ),
      ),
        child: Padding(
          padding: const EdgeInsets.all(13),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Flexible(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Image(
                      image: AssetImage(
                          'assets/images/${deviceInfo.icon}'),
                      width: Platform.isAndroid || Platform.isIOS ? 41 : 34, 
                      height: Platform.isAndroid || Platform.isIOS ? 41 : 34, 
                      fit: BoxFit.fill,
                    ),
                    SizedBox(width: Platform.isAndroid || Platform.isIOS ? 12 : 10),
                    Flexible(
                      child: Text(
                        deviceInfo.name,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: Theme.of(context).flixColors.text.primary,
                           fontSize: Platform.isAndroid || Platform.isIOS ? 16 : 14, 
                        ).fix(),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              badge > 0
                  ? Badge(
                      backgroundColor: Colors.red,
                      textColor:
                          Theme.of(context).flixColors.text.primary,
                    )
                  : Badge(
                      backgroundColor:
                          const Color.fromARGB(0, 244, 67, 54),
                      textColor:
                          Theme.of(context).flixColors.text.primary,
                    ),
              const SizedBox(width: 5),
              SvgPicture.asset(
                'assets/images/arrow_right.svg',
                width: 24,
                height: 24,
                colorFilter: ColorFilter.mode(
                  Theme.of(context).flixColors.text.secondary,
                  BlendMode.srcIn,
                ),
              ),
            ],
          ),
        ),
          ), 
      ),
            )
    );
  }
}