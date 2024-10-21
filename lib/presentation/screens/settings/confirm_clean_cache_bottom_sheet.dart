import 'package:flix/presentation/widgets/flix_bottom_sheet.dart';
import 'package:flix/theme/theme_extensions.dart';
import 'package:flix/utils/void_future_callback.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

import '../../../l10n/l10n.dart';

class ConfirmCleanCacheBottomSheet extends StatelessWidget {
  final VoidFutureCallback onConfirm;

  const ConfirmCleanCacheBottomSheet({super.key, required this.onConfirm});

  @override
  Widget build(BuildContext context) {
    return FlixBottomSheet(
      backgroundGradient:  [
        Theme.of(context).flixColors.gradientRed.first,
        Theme.of(context).flixColors.gradientRed.second,
        Theme.of(context).flixColors.gradientRed.third
      ],
      buttonColor: const Color.fromRGBO(255, 59, 48, 1),
      title: S.of(context).setting_confirm_clean_cache,
      subTitle: S.of(context).setting_confirm_clean_cache_subtitle,
      buttonText: S.of(context).setting_confirm_clean_cache_action,
      onClickFuture: onConfirm,
      child: Padding(
          padding: const EdgeInsets.only(top: 16, bottom: 24),
          child: Align(
              heightFactor: 1.0,
              child: SvgPicture.asset('assets/images/ic_big_delete.svg'))),
    );
  }
}
