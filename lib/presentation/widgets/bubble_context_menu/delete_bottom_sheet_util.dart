import 'package:flutter/cupertino.dart';

import '../../../l10n/l10n.dart';
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
                title: S.of(context).widget_delete_msg_history,
                buttonText: S.of(context).widget_delete_msg_history_action,
                subTitle: S.of(context).widget_delete_msg_history_subtitle));
  }
}
