import 'package:flix/presentation/widgets/flix_bottom_sheet.dart';
import 'package:flix/utils/net/net_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class PairBottomSheet extends StatelessWidget {
  final PairInfo pairInfo;

  const PairBottomSheet({super.key, required this.pairInfo});

  @override
  Widget build(BuildContext context) {
    return FlixBottomSheet(
      title: '添加设备',
      subTitle: '正在添加设备...',
      buttonText: '重试',
      onClickFuture: () async {},
      child: const Padding(
          padding: EdgeInsets.only(top: 16, bottom: 24),
          child: Align(heightFactor: 1.0, child: CircularProgressIndicator())),
    );
  }
}
