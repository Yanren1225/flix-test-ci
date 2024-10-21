import 'package:extended_text/extended_text.dart';
import 'package:flix/domain/androp_context.dart';
import 'package:flix/domain/concert/concert_provider.dart';
import 'package:flix/model/ui_bubble/shared_file.dart';
import 'package:flix/model/ui_bubble/ui_bubble.dart';
import 'package:flix/presentation/basic/corner/flix_decoration.dart';
import 'package:flix/presentation/basic/progressbar/linear/animated_progress_bar.dart';
import 'package:flix/presentation/screens/base_screen.dart';
import 'package:flix/presentation/widgets/segements/cancel_send_button.dart';
import 'package:flix/presentation/widgets/segements/file_bubble_interaction.dart';
import 'package:flix/presentation/widgets/segements/receive_button.dart';
import 'package:flix/presentation/widgets/segements/resend_button.dart';
import 'package:flix/theme/theme_extensions.dart';
import 'package:flix/utils/file/file_helper.dart';
import 'package:flix/utils/file/size_utils.dart';
import 'package:flix/utils/file/speed_utils.dart';
import 'package:flix/utils/text/text_extension.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:gradient_txt/gradient_text.dart';
import 'package:provider/provider.dart';

import '../../../l10n/l10n.dart';

class ShareDirectoryBubble extends StatefulWidget {
  final UIBubble entity;

  const ShareDirectoryBubble({Key? key, required this.entity})
      : super(key: key);

  @override
  State<StatefulWidget> createState() => ShareDirectoryBubbleState();
}

class ShareDirectoryBubbleState<T extends ShareDirectoryBubble>
    extends State<T> {
  UIBubble get entity => widget.entity;
  final _cancelSendButtonKey = GlobalKey();
  final _resendButtonKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    AndropContext andropContext = context.watch();
    // final concertProvider = Provider.of<ConcertProvider>(context, listen: true);
    // final items = concertProvider.bubbles.reversed.toList();
    ConcertProvider concertProvider = context.watch();

    final SharedDirectory sharedDirectory = entity.shareable as SharedDirectory;

    Color backgroundColor = Theme.of(context).flixColors.background.primary;
    Color contentColor = Theme.of(context).flixColors.text.primary;

    final MainAxisAlignment alignment;
    if (entity.isFromMe(andropContext.deviceId)) {
      alignment = MainAxisAlignment.end;
    } else {
      alignment = MainAxisAlignment.start;
    }

    var clickable = false;
    Widget stateIcon = const SizedBox(width: 20, height: 20);
    final bool showProgressBar;
    final List<Color> progressBarColors;
    final size = sharedDirectory.meta.size.formateBinarySize();
    String? stateDes;
    Color? stateDesColor;
    List<Color>? stateDesGradient;
    if (entity.isFromMe(andropContext.deviceId)) {
      switch (sharedDirectory.state) {
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
          stateDes = S.of(context).bubbles_wait_for_confirm;
          stateDesColor = Theme.of(context).flixColors.text.tertiary;
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
          stateDes = '${sharedDirectory.speed.formatSpeed()} '
              '(${sharedDirectory.receiveNum}/${sharedDirectory.sendNum})';
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
          stateDes = S.of(context).bubbles_send_done;
          stateDesColor = const Color.fromRGBO(26, 189, 91, 1);
          break;
        case FileState.sendFailed:
        case FileState.receiveFailed:
        case FileState.failed:
          stateDes = S.of(context).bubbles_send_failed;
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
          stateDes = S.of(context).bubbles_send_cancel;
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
          throw StateError('Unknown send state: ${sharedDirectory.state}');
      }
    } else {
      switch (sharedDirectory.state) {
        case FileState.waitToAccepted:
          showProgressBar = false;
          progressBarColors = [
            const Color.fromRGBO(0, 122, 255, 1),
            const Color.fromRGBO(81, 181, 252, 1)
          ];
          stateDes = S.of(context).bubbles_click_to_accept;
          stateDesColor = const Color.fromRGBO(60, 60, 67, 0.6);
          clickable = false;
          stateIcon =
              ReceiveButton(onTap: () => _confirmReceive(concertProvider));
          break;
        case FileState.inTransit:
        case FileState.sendCompleted:
          clickable = true;
          showProgressBar = true;
          progressBarColors = [
            const Color.fromRGBO(0, 122, 255, 1),
            const Color.fromRGBO(81, 181, 252, 1)
          ];
          stateDes = '${sharedDirectory.speed.formatSpeed()} '
              '(${sharedDirectory.receiveNum}/${sharedDirectory.sendNum})';
          stateDesGradient = [
            const Color.fromRGBO(0, 122, 255, 1),
            const Color.fromRGBO(81, 181, 252, 1)
          ];
          break;
        case FileState.receiveCompleted:
        case FileState.completed:
          clickable = true;
          showProgressBar = false;
          progressBarColors = [
            const Color.fromRGBO(0, 122, 255, 1),
            const Color.fromRGBO(81, 181, 252, 1)
          ];
          stateDes = S.of(context).bubbles_downloaded;
          stateDesColor = const Color.fromRGBO(26, 189, 91, 1);
          break;
        case FileState.sendFailed:
        case FileState.receiveFailed:
        case FileState.failed:
          stateDes = S.of(context).bubbles_receive_failed;
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
          stateDes = S.of(context).bubbles_receive_cancel;
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
          throw StateError('Unknown send state: ${sharedDirectory.state}');
      }
    }

    final innerBubble0 = Container(
      decoration: FlixDecoration(color: backgroundColor),
      child: LayoutBuilder(
        builder: (context, constraints) {
          return SizedBox(
            width: 260,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: 12, top: 10, right: 12),
                  child: Row(
                      mainAxisSize: MainAxisSize.max,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Flexible(
                            child: ExtendedText(sharedDirectory.meta.name,
                                style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w500,
                                        color: contentColor)
                                    .fix(),
                                overflow: TextOverflow.ellipsis,
                                maxLines: 2,
                                overflowWidget: TextOverflowWidget(
                                  position: TextOverflowPosition.middle,
                                  child: Text('\u2026 ',
                                      style: TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.w500,
                                              color: contentColor)
                                          .fix()),
                                ))),
                        const SizedBox(
                          width: 10,
                        ),
                        SizedBox(
                          width: 44,
                          height: 44,
                          child: SvgPicture.asset(
                            mimeIcon('/'),
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
                        visible: sharedDirectory.meta.size > 0,
                        child: Padding(
                          padding: const EdgeInsets.only(right: 10.0),
                          child: Text(
                            size,
                            style: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w400,
                                    color: Color.fromRGBO(60, 60, 67, 0.6))
                                .fix(),
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
                                        color: stateDesColor ??
                                            Theme.of(context)
                                                .flixColors
                                                .text
                                                .secondary)
                                    .fix(),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              )
                            : GradientText(
                                text: stateDes ?? '',
                                gradient: LinearGradient(colors: stateDesGradient),
                                style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w400,
                                        color: contentColor.withOpacity(0.5))
                                    .fix(),
                              ),
                      ),
                    ],
                  ),
                ),
                AnimatedCrossFade(
                  key: ValueKey(sharedDirectory.id),
                  crossFadeState: showProgressBar
                      ? CrossFadeState.showFirst
                      : CrossFadeState.showSecond,
                  firstChild: AnimatedProgressBar(
                      value: sharedDirectory.progress,
                      duration: const Duration(milliseconds: 200),
                      width: double.infinity,
                      height: 6,
                      backgroundColor: Theme.of(context).flixColors.background.primary,
                      gradient: LinearGradient(colors: progressBarColors)),
                  secondChild: const SizedBox(
                    height: 6,
                  ),
                  duration: const Duration(milliseconds: 200),
                )
              ],
            ),
          );
        },
      ),
    );
    Widget innerBubble;
    if (!entity.isFromMe(andropContext.deviceId) &&
        sharedDirectory.state == FileState.waitToAccepted) {
      innerBubble = ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          radius: 12,
          borderRadius: BorderRadius.circular(12),
          onTap: () {
            _confirmReceive(concertProvider);
          },
          child: innerBubble0,
        ),
      );
    } else {
      innerBubble = BubbleInteraction(
        key: ValueKey(entity.shareable.id),
        bubble: entity,
        path: sharedDirectory.meta.path ?? '',
        clickable: clickable,
        child: innerBubble0,
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
