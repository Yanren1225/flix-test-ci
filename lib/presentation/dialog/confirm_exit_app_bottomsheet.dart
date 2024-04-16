import 'package:flix/presentation/widgets/flix_bottom_sheet.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_svg/svg.dart';
import 'package:window_manager/window_manager.dart';

class ConfirmExitAppBottomSheet extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return FlixBottomSheet(
      backgroundGradient: const [
        Color.fromRGBO(255, 243, 242, 1),
        Color.fromRGBO(255, 255, 255, 1),
        Color.fromRGBO(255, 255, 255, 1),
      ],
      buttonColor: const Color.fromRGBO(255, 59, 48, 1),
      title: '退出软件',
      subTitle: '退出后，将无法被附近设备发现。',
      buttonText: '退出',
      onClick: () async {
      Navigator.of(context).pop();
      await windowManager.destroy();
    },
      child: Padding(padding: EdgeInsets.only(top: 16, bottom: 24),child: Align(heightFactor: 1.0, child: SvgPicture.asset('assets/images/ic_big_delete.svg'))),
    );
  }

}