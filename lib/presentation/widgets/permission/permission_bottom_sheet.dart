import 'package:android_intent/android_intent.dart';
import 'package:flix/domain/log/flix_log.dart';
import 'package:flix/model/ui_bubble/ui_bubble.dart';
import 'package:flix/presentation/widgets/flix_bottom_sheet.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:package_info_plus/package_info_plus.dart';

class PermissionBottomSheet extends StatelessWidget {

  const PermissionBottomSheet({Key? key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    // TODO 改造为通用权限弹窗
    return FlixBottomSheet(
      title: '存储权限',
      subTitle: '接收文件需要设备的存储权限，请点击「确认」跳转至App设置页面开启存储权限',
      buttonText: '确认',
      onClick: _openAppSettings,
      child: Padding(padding: EdgeInsets.only(top: 16, bottom: 24),child: Align(heightFactor: 1.0, child: SvgPicture.asset('assets/images/ic_permissions.svg'))),
    );
  }

  Future<void> _openAppSettings() async {
    try {
      final info = await PackageInfo.fromPlatform();
      AndroidIntent intent = AndroidIntent(
        action: "android.settings.APPLICATION_DETAILS_SETTINGS",
        package: info.packageName,
        data: "package:${info.packageName}",
      );
      await intent.launch();
    } catch (e, stackTrace) {
      talker.error('failed to launch settings', e, stackTrace);
    }

  }
}
