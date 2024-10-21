import 'package:flix/domain/version/version_checker.dart';
import 'package:flix/presentation/widgets/flix_bottom_sheet.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_svg/svg.dart';

import '../../l10n/l10n.dart';

class NewVersionBottomSheet extends StatelessWidget {
  final String version;

  const NewVersionBottomSheet({super.key, required this.version});


  @override
  Widget build(BuildContext context) {
    return FlixBottomSheet(
      title: S.of(context).dialog_new_version_title,
      subTitle: S.of(context).dialog_new_version_subtitle,
      buttonText: S.of(context).dialog_new_version_button,
      onClickFuture: () async {
        VersionChecker.openDownloadUrl(version, () => null, (errorTips) => null);
        // Navigator.of(context).pop();
      },
      child: Padding(
          padding: const EdgeInsets.only(top: 16, bottom: 24),
          child: Align(
              heightFactor: 1.0,
              child: SvgPicture.asset('assets/images/ic_big_upgrade.svg'))),
    );
  }
}
