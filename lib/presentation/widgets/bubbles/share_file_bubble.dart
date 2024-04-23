import 'dart:math';

import 'package:flix/domain/androp_context.dart';
import 'package:flix/domain/concert/concert_provider.dart';
import 'package:flix/model/ui_bubble/shared_file.dart';
import 'package:flix/presentation/basic/progressbar/linear/animated_progress_bar.dart';
import 'package:flix/presentation/screens/base_screen.dart';
import 'package:flix/presentation/widgets/bubbles/base_file_bubble.dart';
import 'package:flix/presentation/widgets/segements/cancel_send_button.dart';
import 'package:flix/presentation/widgets/segements/file_bubble_interaction.dart';
import 'package:flix/presentation/widgets/segements/receive_button.dart';
import 'package:flix/presentation/widgets/segements/resend_button.dart';
import 'package:flix/utils/file/file_helper.dart';
import 'package:flix/utils/file/size_utils.dart';
import 'package:flix/utils/file/speed_utils.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:gradient_txt/gradient_text.dart';
import 'package:provider/provider.dart';

class ShareFileBubble extends BaseFileBubble {
  const ShareFileBubble({super.key, required super.entity});

  @override
  State<StatefulWidget> createState() => ShareFileBubbleState();
}

class ShareFileBubbleState extends BaseFileBubbleState<ShareFileBubble> {
  final _cancelSendButtonKey = GlobalKey();
  final _resendButtonKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    AndropContext andropContext = context.watch();
    ConcertProvider concertProvider = context.watch();

    final SharedFile sharedFile = entity.shareable as SharedFile;

    const Color backgroundColor = Colors.white;
    const Color contentColor = Colors.black;

    final MainAxisAlignment alignment;
    if (entity.isFromMe(andropContext.deviceId)) {
      alignment = MainAxisAlignment.end;
    } else {
      alignment = MainAxisAlignment.start;
    }

    var clickable = false;
    Widget stateIcon = const SizedBox(width: 20, height: 20);
    final showProgressBar;
    final progressBarColors;
    final size = sharedFile.content.size.formateBinarySize();
    String? stateDes = null;
    Color? stateDesColor = null;
    List<Color>? stateDesGradient = null;
    if (entity.isFromMe(andropContext.deviceId)) {
      switch (sharedFile.state) {
        case FileState.picked:
          showProgressBar = true;
          progressBarColors = [
            const Color.fromRGBO(0, 122, 255, 1),
            const Color.fromRGBO(81, 181, 252, 1)
          ];
          clickable = true;
          stateIcon =
              CancelSendButton(key: _cancelSendButtonKey, entity: entity);
          break;
        case FileState.waitToAccepted:
          showProgressBar = true;
          progressBarColors = [
            const Color.fromRGBO(0, 122, 255, 1),
            const Color.fromRGBO(81, 181, 252, 1)
          ];
          stateDes = '等待对方确认';
          stateDesColor = const Color.fromRGBO(60, 60, 67, 0.6);
          clickable = true;
          stateIcon =
              CancelSendButton(key: _cancelSendButtonKey, entity: entity);
          break;
        case FileState.inTransit:
          showProgressBar = true;
          progressBarColors = [
            const Color.fromRGBO(0, 122, 255, 1),
            const Color.fromRGBO(81, 181, 252, 1)
          ];
          stateDes = sharedFile.speed.formatSpeed();
          stateDesGradient = [
            const Color.fromRGBO(0, 122, 255, 1),
            const Color.fromRGBO(81, 181, 252, 1)
          ];
          clickable = true;
          stateIcon =
              CancelSendButton(key: _cancelSendButtonKey, entity: entity);
          break;
        case FileState.sendCompleted:
        case FileState.receiveCompleted:
        case FileState.completed:
          clickable = true;
          showProgressBar = false;
          progressBarColors = [
            const Color.fromRGBO(0, 122, 255, 1),
            const Color.fromRGBO(81, 181, 252, 1)
          ];
          stateDes = '已发送';
          stateDesColor = const Color.fromRGBO(26, 189, 91, 1);
          break;
        case FileState.sendFailed:
        case FileState.receiveFailed:
        case FileState.failed:
          stateDes = '发送异常';
          stateDesColor = const Color.fromRGBO(255, 59, 48, 1);
          showProgressBar = true;
          progressBarColors = [
            const Color.fromRGBO(255, 59, 48, 1),
            const Color.fromRGBO(255, 59, 48, 1)
          ];
          clickable = true;
          stateIcon = ResendButton(key: _resendButtonKey, entity: entity);
          break;
        case FileState.cancelled:
          stateDes = '已取消';
          stateDesColor = const Color.fromRGBO(255, 59, 48, 1);
          showProgressBar = true;
          progressBarColors = [
            const Color.fromRGBO(255, 59, 48, 1),
            const Color.fromRGBO(255, 59, 48, 1)
          ];
          clickable = true;
          stateIcon =
              stateIcon = ResendButton(key: _resendButtonKey, entity: entity);
          break;
        case FileState.unknown:
          throw StateError('Unknown send state: ${sharedFile.state}');
      }
    } else {
      switch (sharedFile.state) {
        case FileState.waitToAccepted:
          showProgressBar = false;
          progressBarColors = [
            Color.fromRGBO(0, 122, 255, 1),
            Color.fromRGBO(81, 181, 252, 1)
          ];
          stateDes = '点击确认接收';
          stateDesColor = const Color.fromRGBO(60, 60, 67, 0.6);
          clickable = false;
          stateIcon =
              ReceiveButton(onTap: () => _confirmReceive(concertProvider));
          break;
        case FileState.inTransit:
        case FileState.sendCompleted:
          clickable = false;
          showProgressBar = true;
          progressBarColors = [
            Color.fromRGBO(0, 122, 255, 1),
            Color.fromRGBO(81, 181, 252, 1)
          ];
          stateDes = sharedFile.speed.formatSpeed();
          stateDesGradient = [
            Color.fromRGBO(0, 122, 255, 1),
            Color.fromRGBO(81, 181, 252, 1)
          ];
          break;
        case FileState.receiveCompleted:
        case FileState.completed:
          clickable = true;
          showProgressBar = false;
          progressBarColors = [
            Color.fromRGBO(0, 122, 255, 1),
            Color.fromRGBO(81, 181, 252, 1)
          ];
          stateDes = '已下载';
          stateDesColor = const Color.fromRGBO(26, 189, 91, 1);
          break;
        case FileState.sendFailed:
        case FileState.receiveFailed:
        case FileState.failed:
          stateDes = '接收失败';
          stateDesColor = const Color.fromRGBO(255, 59, 48, 1);
          showProgressBar = true;
          progressBarColors = [
            const Color.fromRGBO(255, 59, 48, 1),
            const Color.fromRGBO(255, 59, 48, 1)
          ];
          clickable = false;
          stateIcon = SvgPicture.asset(
            'assets/images/ic_trans_fail.svg',
          );
          break;
        case FileState.cancelled:
          stateDes = '已取消';
          stateDesColor = const Color.fromRGBO(255, 59, 48, 1);
          showProgressBar = true;
          progressBarColors = [
            const Color.fromRGBO(255, 59, 48, 1),
            const Color.fromRGBO(255, 59, 48, 1)
          ];
          clickable = false;
          stateIcon = SvgPicture.asset(
            'assets/images/ic_trans_fail.svg',
          );
          break;
        case FileState.unknown:
        default:
          throw StateError('Unknown send state: ${sharedFile.state}');
      }
    }

    final _innerBubble = Container(
      decoration: const BoxDecoration(color: backgroundColor),
      child: LayoutBuilder(
        builder: (context, constraints) {
          return SizedBox(
            width: 260,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding:
                      const EdgeInsets.only(left: 12, top: 10, right: 12),
                  child: Row(
                      mainAxisSize: MainAxisSize.max,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Flexible(
                          child: Text(
                            sharedFile.content.name,
                            style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                                color: contentColor),
                            maxLines: 2,
                            // TODO: 省略中间
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(
                          width: 10,
                        ),
                        SizedBox(
                          width: 44,
                          height: 44,
                          child: SvgPicture.asset(
                            mimeIcon(sharedFile.content.nameWithSuffix),
                            width: 44,
                            height: 44,
                          ),
                        ),
                      ]),
                ),
                Padding(
                  padding: const EdgeInsets.only(
                      left: 12, top: 8.0, right: 12, bottom: 6),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Visibility(
                        visible: sharedFile.content.size > 0,
                        child: Padding(
                          padding: const EdgeInsets.only(right: 10.0),
                          child: Text(
                            size,
                            style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w400,
                                color: Color.fromRGBO(60, 60, 67, 0.6)),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ),
                      Visibility(
                        visible: stateDes != null,
                        child: stateDesGradient == null
                            ? Text(
                                stateDes ?? '',
                                style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w400,
                                    color: stateDesColor ?? Colors.grey),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              )
                            : GradientText(
                                text: stateDes ?? '',
                                gradient: LinearGradient(
                                    colors: stateDesGradient ?? []),
                                style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w400,
                                    color: contentColor.withOpacity(0.5)),
                              ),
                      ),
                    ],
                  ),
                ),
                AnimatedCrossFade(
                  key: ValueKey(sharedFile.id),
                  crossFadeState: showProgressBar
                      ? CrossFadeState.showFirst
                      : CrossFadeState.showSecond,
                  firstChild: AnimatedProgressBar(
                      value: sharedFile.progress,
                      duration: const Duration(milliseconds: 200),
                      width: double.infinity,
                      height: 6,
                      backgroundColor: const Color.fromRGBO(247, 247, 247, 1),
                      gradient: LinearGradient(colors: progressBarColors)),
                  secondChild: const SizedBox(
                    height: 6,
                  ),
                  duration: Duration(milliseconds: 200),
                )
              ],
            ),
          );
        },
      ),
    );
    Widget innerBubble;
    if (!entity.isFromMe(andropContext.deviceId) &&
        sharedFile.state == FileState.waitToAccepted) {
      innerBubble = ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          radius: 12,
          borderRadius: BorderRadius.circular(12),
          onTap: () {
            _confirmReceive(concertProvider);
          },
          child: _innerBubble,
        ),
      );
    } else {
      innerBubble = FileBubbleInteraction(
        key: ValueKey(entity.shareable.id),
        bubble: entity,
        filePath: sharedFile.content.path ?? '',
        child: _innerBubble,
        clickable: clickable,
      );
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
                : const SizedBox.shrink(),
            child: Padding(
              padding: const EdgeInsets.only(right: 18.0),
              child: stateIcon,
            )),
        Flexible(
          child: innerBubble,
        ),
        Visibility(
            visible: alignment == MainAxisAlignment.start,
            replacement: alignment == MainAxisAlignment.start
                ? const SizedBox(
                    width: 20 + 18,
                    height: 20,
                  )
                : const SizedBox.shrink(),
            child: Padding(
              padding: const EdgeInsets.only(left: 18.0),
              child: stateIcon,
            )),
      ],
    );
  }

  void _confirmReceive(ConcertProvider concertProvider) async {
    if (await checkStoragePermission(context)) {
      concertProvider.confirmReceive(entity);
    }
  }
}
