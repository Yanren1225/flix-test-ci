import 'package:flix/presentation/widgets/flix_bottom_sheet.dart';
import 'package:flix/utils/net/net_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

import '../../../l10n/l10n.dart';

class PairBottomSheet extends StatelessWidget {
  final PairInfo pairInfo;

  const PairBottomSheet({super.key, required this.pairInfo});

  @override
  Widget build(BuildContext context) {
    return FlixBottomSheet(
      title: S.of(context).paircode_dialog_add_device,
      subTitle: S.of(context).paircode_dialog_adding_device,
      buttonText: S.of(context).paircode_dialog_add_device_action,
      onClickFuture: () async {},
      child: const Padding(
          padding: EdgeInsets.only(top: 16, bottom: 24),
          child: Align(heightFactor: 1.0, child: CircularProgressIndicator())),
    );
  }
}
