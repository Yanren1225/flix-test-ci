import 'package:flix/presentation/widgets/flix_bottom_sheet.dart';
import 'package:flutter/widgets.dart';
import 'package:window_manager/window_manager.dart';

class ConfirmExitAppBottomSheet extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return FlixBottomSheet(title: '退出软件', subTitle: '退出后将无法建立连接', buttonText: '退出', child: SizedBox(height: 16,),onClick: () async {
      Navigator.of(context).pop();
      await windowManager.destroy();
    },);
  }

}