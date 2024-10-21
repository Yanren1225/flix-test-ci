import 'package:flix/presentation/widgets/flix_bottom_sheet.dart';
import 'package:flix/utils/void_future_callback.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../l10n/l10n.dart';

class DeleteMessageBottomSheet extends StatelessWidget {
  final VoidFutureCallback onConfirm;

  const DeleteMessageBottomSheet({Key? key, required this.onConfirm})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FlixBottomSheet(
      buttonColor: const Color.fromRGBO(255, 59, 48, 1),
      title: S.of(context).widget_recommend,
      subTitle: S.of(context).widget_recommend_subtitle,
      buttonText: S.of(context).widget_recommend_action,
      onClick: onConfirm,
      child: Padding(
          padding: const EdgeInsets.only(top: 16, bottom: 24),
          child:
              Align(heightFactor: 1.0, child: SvgPicture.asset('assets/images/ic_big_delete.svg'))),
    );
  }
}
