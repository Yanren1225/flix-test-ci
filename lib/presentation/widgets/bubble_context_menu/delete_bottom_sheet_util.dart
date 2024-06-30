import 'package:flutter/cupertino.dart';

import 'delete_bottom_sheet.dart';

class BottomSheetUtil {
  static void showMessageDelete(BuildContext context, VoidCallback onConfirm) {
    showCupertinoModalPopup(
        context: context,
        builder: (context) =>
            DeleteConfirmBottomSheet(
                onConfirm: () {
                  onConfirm();
                },
                title: "删除消息记录",
                buttonText: '删除',
                subTitle: "如果文件正在传输，删除消息会中断传输"));
  }
}
