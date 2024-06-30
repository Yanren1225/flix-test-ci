import 'package:flix/presentation/widgets/flix_bottom_sheet.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_svg/flutter_svg.dart';

class PermissionBottomSheet extends StatelessWidget {

  final String title;
  final String subTitle;
  final Future<void> Function() onConfirm;

  const PermissionBottomSheet(
      {Key? key, required this.title, required this.subTitle, required this.onConfirm})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FlixBottomSheet(
      title: title,
      subTitle: subTitle,
      buttonText: '确认',
      onClickFuture: onConfirm,
      child: Padding(
          padding: const EdgeInsets.only(top: 16, bottom: 24),
          child: Align(
              heightFactor: 1.0, child: SvgPicture.asset('assets/images/ic_permissions.svg'))),
    );
  }

}
