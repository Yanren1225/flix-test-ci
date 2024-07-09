import 'package:flix/domain/androp_context.dart';
import 'package:flix/model/ui_bubble/shared_file.dart';
import 'package:flix/model/ui_bubble/ui_bubble.dart';
import 'package:flix/presentation/widgets/segements/cancel_send_button.dart';
import 'package:flix/presentation/widgets/segements/resend_button.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';

class BubbleDecorationWidget extends StatefulWidget {
  final UIBubble entity;
  final Widget child;

  const BubbleDecorationWidget(
      {super.key, required this.entity, required this.child});

  @override
  State<StatefulWidget> createState() => _BubbleDecorationWidgetState();
}

class _BubbleDecorationWidgetState extends State<BubbleDecorationWidget> {
  final _cancelSendButtonKey = GlobalKey();
  final _resendButtonKey = GlobalKey();

  UIBubble get entity => widget.entity;

  Widget get child => widget.child;

  @override
  Widget build(BuildContext context) {
    assert(entity.shareable is SharedFile);
    final sharedFile = entity.shareable as SharedFile;
    AndropContext andropContext = Provider.of(context, listen: false);
    final isFromMe = widget.entity.isFromMe(andropContext.deviceId);
    final alignment;
    if (isFromMe) {
      alignment = MainAxisAlignment.end;
    } else {
      alignment = MainAxisAlignment.start;
    }
    Widget stateIcon = const SizedBox(
      width: 20,
      height: 20,
    );
    if (isFromMe) {
      if (sharedFile.state == FileState.picked ||
          sharedFile.state == FileState.waitToAccepted ||
          sharedFile.state == FileState.inTransit) {
        stateIcon = CancelSendButton(key: _cancelSendButtonKey, entity: entity);
      } else if (sharedFile.state == FileState.cancelled ||
          sharedFile.state == FileState.sendFailed ||
          sharedFile.state == FileState.receiveFailed ||
          sharedFile.state == FileState.failed) {
        stateIcon = ResendButton(key: _resendButtonKey, entity: entity);
      }
    } else {
      if (sharedFile.state == FileState.cancelled ||
          sharedFile.state == FileState.sendFailed ||
          sharedFile.state == FileState.receiveFailed ||
          sharedFile.state == FileState.failed) {
        stateIcon = SvgPicture.asset('assets/images/ic_trans_fail.svg');
      }
    }

    return Row(
      mainAxisAlignment: alignment,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Visibility(
          visible: alignment == MainAxisAlignment.end,
          replacement: alignment == MainAxisAlignment.end
              ? const SizedBox(
                  width: 20 + 18,
                  height: 20,
                )
              : SizedBox.shrink(),
          child: Padding(
            padding: const EdgeInsets.only(right: 18.0),
            child: stateIcon,
          ),
        ),
        // Expanded强制占用剩余的空间
        // Flexible默认允许子元素占用尽可能的剩余空间
        Flexible(
          child: child,
        ),
        Visibility(
          visible: alignment == MainAxisAlignment.start,
          replacement: alignment == MainAxisAlignment.start
              ? SizedBox(
                  width: 20 + 18,
                  height: 20,
                )
              : SizedBox.shrink(),
          child: Padding(
            padding: const EdgeInsets.only(left: 18.0),
            child: stateIcon,
          ),
        ),
      ],
    );
  }
}
