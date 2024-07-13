import 'package:flix/domain/log/flix_log.dart';
import 'package:flix/theme/theme_extensions.dart';
import 'package:flix/utils/text/text_extension.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class Toolbar extends StatefulWidget {
  final bool showBack;
  final String title;

  const Toolbar({super.key, this.showBack = false, required this.title});

  @override
  State<StatefulWidget> createState() => ToolbarState();
}

class ToolbarState extends State<Toolbar> {
  @override
  Widget build(BuildContext context) {
    talker.debug("ToolbarState showBack = ${widget.showBack}");
    return Column(
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
                child: SizedBox(
                    height: 56,
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: SvgPicture.asset('assets/images/ic_back.svg',
                          width: 24,
                          height: 24,
                          colorFilter: ColorFilter.mode(
                              Theme.of(context).flixColors.text.primary,
                              BlendMode.srcIn)),
                    )))),
        SizedBox(
            height: 68,
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                widget.title,
                style: const TextStyle(fontSize: 36).fix(),
              ),
            ))
      ],
    );
  }
}
