import 'package:flix/domain/log/flix_log.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class Toolbar extends StatefulWidget {
  bool showBack = false;
  String title = "";

  Toolbar({super.key, required this.showBack, required this.title});

  @override
  State<StatefulWidget> createState() => ToolbarState();
}

class ToolbarState extends State<Toolbar> {
  @override
  Widget build(BuildContext context) {
    talker.debug("ToolbarState showBack = ${widget.showBack}");
    return Container(
        child: Column(
          children: [
            Visibility(
                visible: widget.showBack,
                maintainSize: true,
                maintainAnimation: true,
                maintainState: true,
                child: InkWell(
                    onTap: () {
                      Navigator.pop(context);
                    },
                    child: Container(
                        height: 56,
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: SvgPicture.asset('assets/images/ic_back.svg',
                              width: 24, height: 24),
                        )))),
            Container(
                height: 68,
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    widget.title,
                    style: TextStyle(fontSize: 36),
                  ),
                ))
          ],
        ));
  }
}