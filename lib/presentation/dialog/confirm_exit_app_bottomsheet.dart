import 'package:flix/presentation/widgets/flix_bottom_sheet.dart';
import 'package:flix/theme/theme_extensions.dart';
import 'package:flix/utils/exit.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_svg/svg.dart';
import 'package:window_manager/window_manager.dart';

import '../../l10n/l10n.dart';

class ConfirmExitAppBottomSheet extends StatelessWidget {
  const ConfirmExitAppBottomSheet({super.key});

  @override
  Widget build(BuildContext context) {
    return FlixBottomSheet(
      backgroundGradient:  [
        Theme.of(context).flixColors.gradientRed.first,
        Theme.of(context).flixColors.gradientRed.second,
        Theme.of(context).flixColors.gradientRed.third
      ],
      buttonColor: const Color.fromRGBO(255, 59, 48, 1),
      title: S.of(context).dialog_exit_title,
      subTitle: S.of(context).dialog_exit_subtitle,
      buttonText: S.of(context).dialog_exit_button,
      onClickFuture: () async {
        doExit();
    },
      child: Padding(
          padding: const EdgeInsets.only(top: 16, bottom: 24),
          child:
              Align(heightFactor: 1.0, child: SvgPicture.asset('assets/images/ic_big_delete.svg'))),
    );
  }

}