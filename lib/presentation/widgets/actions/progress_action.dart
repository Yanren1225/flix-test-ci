import 'package:flix/presentation/widgets/flix_toast.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_svg/svg.dart';

class ProgressAction extends StatefulWidget {
  final bool showProgress;
  final String icon;
  final VoidCallback onTap;

  const ProgressAction({Key? super.key, this.showProgress = false, required this.icon, required this.onTap});

  @override
  State<StatefulWidget> createState() => _ProgressActionState();
}

class _ProgressActionState extends State<ProgressAction> {

  bool get showProgress => widget.showProgress;
  String get icon => widget.icon;
  VoidCallback get onTap => widget.onTap;

  @override
  Widget build(BuildContext context) {
    return AnimatedCrossFade(
      crossFadeState: showProgress
          ? CrossFadeState.showSecond
          : CrossFadeState.showFirst,
      duration: const Duration(milliseconds: 200),
      firstChild: SizedBox(
        width: 50,
        height: 50,
        child: IconButton(
          padding: const EdgeInsets.all(0),
          iconSize: 22,
          onPressed: onTap,
          icon: SvgPicture.asset(
            icon,
            width: 22,
            height: 22,
          ),
        ),
      ),
      secondChild: SizedBox(
        width: 50,
        height: 50,
        child: IconButton(
          padding: const EdgeInsets.all(0),
          iconSize: 22,
          onPressed: () {
            flixToast.alert('正在准备发送，请稍候');
          },
          icon: const SizedBox(
              width: 16.5,
              height: 16.5,
              child: CircularProgressIndicator(
                backgroundColor: Colors.transparent,
                color: Color.fromRGBO(0, 122, 255, 1),
                strokeWidth: 2.0,
              )),
        ),
      ),
    );
  }

}