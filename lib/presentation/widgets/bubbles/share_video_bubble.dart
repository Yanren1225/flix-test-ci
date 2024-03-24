import 'dart:math';

import 'package:flix/domain/androp_context.dart';
import 'package:flix/domain/concert/concert_provider.dart';
import 'package:flix/model/ui_bubble/shared_file.dart';
import 'package:flix/model/ui_bubble/ui_bubble.dart';
import 'package:flix/presentation/widgets/aspect_ratio_video.dart';
import 'package:flix/presentation/widgets/bubbles/accept_media_widget.dart';
import 'package:flix/presentation/widgets/bubbles/wait_to_accept_media_widget.dart';
import 'package:flix/presentation/widgets/segements/cancel_send_button.dart';
import 'package:flix/presentation/widgets/segements/file_bubble_interaction.dart';
import 'package:flix/presentation/widgets/segements/resend_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import 'package:video_player/video_player.dart';

class ShareVideoBubble extends StatefulWidget {
  final UIBubble entity;

  const ShareVideoBubble({super.key, required this.entity});

  @override
  State<StatefulWidget> createState() => ShareVideoBubbleState();
}

class ShareVideoBubbleState extends State<ShareVideoBubble> {
  UIBubble get entity => widget.entity;
  VideoPlayerController? controller;

  final _cancelButtonKey = GlobalKey();
  final _resendButtonKey = GlobalKey();
  final _videoWidget = GlobalKey();

  @override
  Widget build(BuildContext context) {
    AndropContext andropContext = context.watch();
    ConcertProvider concertProvider = context.watch();
    final sharedVideo = entity.shareable as SharedFile;
    final Color backgroundColor;
    if (entity.isFromMe(andropContext.deviceId)) {
      backgroundColor = const Color.fromRGBO(0, 122, 255, 1);
    } else {
      backgroundColor = Colors.white;
    }

    var clickable = false;
    final MainAxisAlignment alignment;
    if (entity.isFromMe(andropContext.deviceId)) {
      alignment = MainAxisAlignment.end;
    } else {
      alignment = MainAxisAlignment.start;
    }

    Widget stateIcon = SizedBox();
    final Widget content;
    if (entity.isFromMe(andropContext.deviceId)) {
      // 发送
      switch (sharedVideo.state) {
        case FileState.picked:
          clickable = true;
          content = _buildInlineVideoPlayer(sharedVideo.content.path!, false);
          stateIcon = CancelSendButton(key: _cancelButtonKey, entity: entity);
          break;
        case FileState.waitToAccepted:
          clickable = false;
          content = Stack(
            fit: StackFit.passthrough,
            children: [
              _buildInlineVideoPlayer(sharedVideo.content.path!, true),
              Container(
                decoration:
                    const BoxDecoration(color: Color.fromRGBO(0, 0, 0, 0.5)),
                width: double.infinity,
                height: double.infinity,
                child: const SizedBox(),
              ),
              const Align(
                alignment: Alignment.center,
                child: WaitToAcceptMediaWidget(),
              )
            ],
          );
          stateIcon = CancelSendButton(key: _cancelButtonKey, entity: entity);
          break;
        case FileState.inTransit:
          clickable = false;
          content = Stack(
            fit: StackFit.passthrough,
            children: [
              _buildInlineVideoPlayer(sharedVideo.content.path!, true),
              Container(
                decoration: BoxDecoration(color: Colors.black.withOpacity(0.5)),
                width: double.infinity,
                height: double.infinity,
              ),
              Align(
                alignment: Alignment.center,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          backgroundColor: Colors.transparent,
                          color: Colors.white,
                          strokeWidth: 2.0,
                        )),
                    const SizedBox(
                      height: 8,
                    ),
                    Text(
                      '${(sharedVideo.progress * 100).round()}%',
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.normal),
                    )
                  ],
                ),
              )
            ],
          );
          stateIcon = CancelSendButton(key: _cancelButtonKey, entity: entity);
          break;
        case FileState.sendCompleted:
        case FileState.receiveCompleted:
        case FileState.completed:
          clickable = true;
          content = _buildInlineVideoPlayer(sharedVideo.content.path!, false);
          break;
        case FileState.cancelled:
        case FileState.sendFailed:
        case FileState.receiveFailed:
        case FileState.failed:
          clickable = true;
          content = _buildInlineVideoPlayer(sharedVideo.content.path!, false);
          stateIcon = ResendButton(key: _resendButtonKey, entity: entity);
          break;
        default:
          throw StateError('Error send state: ${sharedVideo.state}');
      }
    } else {
      // 接收
      switch (sharedVideo.state) {
        case FileState.waitToAccepted:
          content = InkWell(
            onTap: () {
              concertProvider.confirmReceive(entity);
            },
            child: AcceptMediaWidget(),
          );
          break;
        case FileState.inTransit:
        case FileState.sendCompleted:
          content = AspectRatio(
            aspectRatio: 1.333333,
            child: DecoratedBox(
              decoration:
                  const BoxDecoration(color: Color.fromRGBO(0, 0, 0, 0.5)),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text('${(sharedVideo.progress * 100).round()}%',
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.normal))
                ],
              ),
            ),
          );
        case FileState.receiveCompleted:
        case FileState.completed:
          clickable = true;
          content = _buildInlineVideoPlayer(sharedVideo.content.path!, false);
        case FileState.cancelled:
        case FileState.sendFailed:
        case FileState.receiveFailed:
        case FileState.failed:
          content = const AspectRatio(
            aspectRatio: 1.333333,
            child: DecoratedBox(
              decoration: BoxDecoration(color: Color.fromRGBO(0, 0, 0, 0.5)),
            ),
          );
          stateIcon = SvgPicture.asset('assets/images/ic_trans_fail.svg');
          break;
        default:
          throw StateError('Error receive state: ${sharedVideo.state}');
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
              : const SizedBox.shrink(),
          child: Padding(
            padding: const EdgeInsets.only(right: 18.0),
            child: stateIcon,
          ),
        ),
        Flexible(
          child: FileBubbleInteraction(
            key: ValueKey(entity.shareable.id),
            bubble: entity,
            filePath: sharedVideo.content.path ?? '',
            clickable: clickable,
            child: Container(
              decoration: BoxDecoration(
                  color: backgroundColor,
                  borderRadius: const BorderRadius.all(Radius.circular(10))),
              child: LayoutBuilder(
                  builder: (BuildContext context, BoxConstraints constraints) {
                final width;
                if (sharedVideo.content.width >
                    max(150, min(300, constraints.maxWidth - 60))) {
                  width = max(150, min(300, constraints.maxWidth - 60));
                } else if (sharedVideo.content.width < 150) {
                  width = 150;
                } else {
                  width = sharedVideo.content.width;
                }
                final height;

                if (sharedVideo.content.width == 0) {
                  height = width;
                } else {
                  height = sharedVideo.content.height *
                      1.0 /
                      sharedVideo.content.width *
                      width;
                }
                return SizedBox(
                  width: width * 1.0,
                  height: height * 1.0,
                  child: ClipRRect(
                      borderRadius: const BorderRadius.all(Radius.circular(10)),
                      child: content),
                );
              }),
            ),
          ),
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
          ),
        ),
      ],
    );
  }

  Widget _buildInlineVideoPlayer(
      String videoUri, bool preview) {

    return AspectRatioVideo(
        key: _videoWidget, videoPath: videoUri, preview: preview);
  }
}
