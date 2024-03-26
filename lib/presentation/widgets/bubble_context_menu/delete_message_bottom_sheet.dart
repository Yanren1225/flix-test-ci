import 'package:flix/model/ui_bubble/ui_bubble.dart';
import 'package:flix/presentation/widgets/flix_bottom_sheet.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_svg/flutter_svg.dart';

class DeleteMessageBottomSheet extends StatelessWidget {
  final VoidCallback onConfirm;

  const DeleteMessageBottomSheet({Key? key, required this.onConfirm})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FlixBottomSheet(
      backgroundGradient: const [
        Color.fromRGBO(255, 243, 242, 1),
        Color.fromRGBO(255, 255, 255, 1),
        Color.fromRGBO(255, 255, 255, 1),
      ],
      buttonColor: const Color.fromRGBO(255, 59, 48, 1),
      title: '删除消息记录',
      subTitle: '如果文件正在传输，删除消息会中断传输',
      buttonText: '删除',
      onClick: onConfirm,
      child: Padding(padding: EdgeInsets.only(top: 16, bottom: 24),child: Align(heightFactor: 1.0, child: SvgPicture.asset('assets/images/ic_big_delete.svg'))),
    );
  }
}
