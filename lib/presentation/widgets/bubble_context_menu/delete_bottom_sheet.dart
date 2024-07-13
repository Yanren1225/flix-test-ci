import 'package:flix/model/ui_bubble/ui_bubble.dart';
import 'package:flix/presentation/widgets/flix_bottom_sheet.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_svg/flutter_svg.dart';

class DeleteConfirmBottomSheet extends StatelessWidget {
  final VoidCallback onConfirm;
  final String title;
  final String? subTitle;
  final String buttonText;

  const DeleteConfirmBottomSheet(
      {Key? key,
      required this.onConfirm,
      required this.title,
      this.subTitle,
      required this.buttonText})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FlixBottomSheet(
      buttonColor: const Color.fromRGBO(255, 59, 48, 1),
      title: title,
      subTitle: subTitle ?? "",
      buttonText: buttonText,
      onClick: onConfirm,
      child: Padding(
          padding: EdgeInsets.only(top: 16, bottom: 24),
          child: Align(
              heightFactor: 1.0,
              child: SvgPicture.asset('assets/images/ic_big_delete.svg'))),
    );
  }
}
