import 'package:flix/presentation/widgets/flix_bottom_sheet.dart';
import 'package:flix/theme/theme_extensions.dart';
import 'package:flix/utils/void_future_callback.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

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
      title: '清除缓存',
      subTitle: '由于系统限制，发送的文件会被缓存，清除缓存可能中断正在发送的文件，并导致部分已发送文件无法预览，清除缓存不影响接收的文件',
      buttonText: '清除',
      onClickFuture: onConfirm,
      child: Padding(
          padding: const EdgeInsets.only(top: 16, bottom: 24),
          child: Align(
              heightFactor: 1.0,
              child: SvgPicture.asset('assets/images/ic_big_delete.svg'))),
    );
  }
}
