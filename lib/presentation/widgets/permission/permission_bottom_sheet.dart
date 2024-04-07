import 'package:android_intent/android_intent.dart';
import 'package:flix/domain/log/flix_log.dart';
import 'package:flix/model/ui_bubble/ui_bubble.dart';
import 'package:flix/presentation/widgets/flix_bottom_sheet.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:package_info_plus/package_info_plus.dart';

class PermissionBottomSheet extends StatelessWidget {

  final String title;
  final String subTitle;
  final VoidCallback onConfirm;

  PermissionBottomSheet({Key? key, required this.title, required this.subTitle, required this.onConfirm})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FlixBottomSheet(
      title: title,
      subTitle: subTitle,
      buttonText: '确认',
      onClick: onConfirm,
      child: Padding(padding: EdgeInsets.only(top: 16, bottom: 24),child: Align(heightFactor: 1.0, child: SvgPicture.asset('assets/images/ic_permissions.svg'))),
    );
  }

}
