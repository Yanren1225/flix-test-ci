import 'package:flix/presentation/widgets/flix_bottom_sheet.dart';
import 'package:flix/presentation/widgets/input/verification_code.dart';
import 'package:flutter/material.dart';

typedef ValueCallback = void Function(String text);

class CrossDeviceShowCodeBottomSheet extends StatelessWidget {
  final ValueCallback? onConfirm;
  final bool isEdit;
  final String? code;
  String curCode = "";

  CrossDeviceShowCodeBottomSheet(
      {Key? key, this.onConfirm, required this.isEdit, this.code = ""})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FlixBottomSheet(
      buttonColor: const Color(0xFF007AFF),
      title: '本机关联码',
      subTitle: '对方输入你的关联码，即可开启跨设备复制粘贴。5分钟内有效。',
      buttonText: '完成',
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
      underlineColor:
          isEdit ? Theme.of(context).primaryColor : Colors.transparent,
      underlineUnfocusedColor:
          isEdit ? Theme.of(context).primaryColor : Colors.transparent,
      length: 4,
      editable: true,
      text: code,
      textStyle: const TextStyle(color: Colors.black, fontSize: 25.0),
      onCompleted: (String value) {
        curCode = value;
      },
      onEditing: (bool value) {},
    );
  }
}
