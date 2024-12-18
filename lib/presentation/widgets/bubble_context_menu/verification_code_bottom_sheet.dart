import 'package:flix/presentation/widgets/flix_bottom_sheet.dart';
import 'package:flix/presentation/widgets/input/verification_code.dart';
import 'package:flix/theme/theme_extensions.dart';
import 'package:flutter/material.dart';

import '../../../l10n/l10n.dart';

typedef ValueCallback = void Function(String text);

class CrossDeviceShowCodeBottomSheet extends StatelessWidget {
  final ValueCallback? onConfirm;
  final bool isEdit;
  final String title;
  final String subtitle;
  final String? code;
  String curCode = "";

  CrossDeviceShowCodeBottomSheet(
      {Key? key, this.onConfirm, required this.isEdit,required this.title,required this.subtitle, this.code = ""})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FlixBottomSheet(
      buttonColor: const Color(0xFF007AFF),
      title: title,
      subTitle: subtitle,
      buttonText: S.of(context).widget_verification_action,
      onClick: () {
        if (curCode.isNotEmpty == true && curCode.length == 4) {
          onConfirm?.call(curCode);
        }
      },
      child: Container(
          height: 100,
          width: double.infinity,
          child: Center(
              child: AbsorbPointer(
                  absorbing: !isEdit,
                  child: Padding(
                      padding: const EdgeInsets.only(top: 16, bottom: 24),
                      child: createVerification(context))))),
    );
  }

  CustomVerificationCode createVerification(BuildContext context) {
    return CustomVerificationCode(
      length: 4,
      editable: true,
      text: code,
      textStyle: Theme.of(context).textTheme.headlineMedium!,
      onCompleted: (String value) {
        curCode = value;
      },
      onEditing: (bool value) {},
    );
  }
}
