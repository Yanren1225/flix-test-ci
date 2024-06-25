import 'package:flix/domain/version/version_checker.dart';
import 'package:flix/presentation/widgets/flix_bottom_sheet.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_svg/svg.dart';

class NewVersionBottomSheet extends StatelessWidget {
  final String version;

  const NewVersionBottomSheet({super.key, required this.version});


  @override
  Widget build(BuildContext context) {
    return FlixBottomSheet(
      title: '发现新版本',
      subTitle: '建议升级到新版本，获得更好的体验哦～',
      buttonText: '升级',
      onClick: () async {
        Navigator.of(context).pop();
        await VersionChecker.openDownloadUrl(version, () => null, (errorTips) => null);
      },
      child: Padding(
          padding: const EdgeInsets.only(top: 16, bottom: 24),
          child: Align(
              heightFactor: 1.0,
              child: SvgPicture.asset('assets/images/ic_big_upgrade.svg'))),
    );
  }
}
