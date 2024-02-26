import 'dart:io';
import 'dart:math';

import 'package:androp/domain/androp_context.dart';
import 'package:androp/domain/concert/concert_provider.dart';
import 'package:androp/model/ui_bubble/shared_file.dart';
import 'package:androp/model/ui_bubble/ui_bubble.dart';
import 'package:androp/presentation/widgets/aspect_ratio_video.dart';
import 'package:androp/presentation/widgets/bubbles/accept_media_widget.dart';
import 'package:androp/presentation/widgets/bubbles/wait_to_accept_media_widget.dart';
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

    if (entity.isFromMe(andropContext.deviceId)) {
    } else {}

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
          content = _buildInlineVideoPlayer(sharedVideo.content.path!, false);
          stateIcon = IconButton(
              onPressed: () {
                concertProvider.cancel(entity);
              },
              icon: SvgPicture.asset(
                'assets/images/ic_cancel.svg',
              ));
          break;
        case FileState.waitToAccepted:
          content = IntrinsicHeight(
            child: Stack(
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
            ),
          );
          stateIcon = IconButton(
              onPressed: () {
                concertProvider.cancel(entity);
              },
              icon: SvgPicture.asset(
                'assets/images/ic_cancel.svg',
              ));
          break;
        case FileState.inTransit:
          content = IntrinsicHeight(
            child: Stack(
              fit: StackFit.passthrough,
              children: [
                _buildInlineVideoPlayer(sharedVideo.content.path!, true),
                Container(
                  decoration:
                      BoxDecoration(color: Colors.black.withOpacity(0.5)),
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
            ),
          );
          stateIcon = IconButton(
              onPressed: () {
                concertProvider.cancel(entity);
              },
              icon: SvgPicture.asset(
                'assets/images/ic_cancel.svg',
              ));
          break;
        case FileState.sendCompleted:
        case FileState.receiveCompleted:
        case FileState.completed:
          content = _buildInlineVideoPlayer(sharedVideo.content.path!, false);
          break;
        case FileState.cancelled:
        case FileState.sendFailed:
        case FileState.receiveFailed:
        case FileState.failed:
          content = _buildInlineVideoPlayer(sharedVideo.content.path!, false);
          stateIcon = IconButton(onPressed: () {
            concertProvider.resend(entity);
          }, icon: SvgPicture.asset('assets/images/ic_trans_fail.svg'));
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
          visible: alignment == MainAxisAlignment.end && stateIcon != SizedBox,
          child: Align(
              alignment: Alignment.bottomCenter,
              child: Padding(
                padding: const EdgeInsets.only(right: 18.0),
                child: stateIcon,
              )),
        ),
        Flexible(
          child: Container(
            decoration: BoxDecoration(
                color: backgroundColor,
                borderRadius: const BorderRadius.all(Radius.circular(10))),
            child: LayoutBuilder(
                builder: (BuildContext context, BoxConstraints constraints) {
              return ConstrainedBox(
                  constraints: BoxConstraints(
                      maxWidth: min(300, constraints.maxWidth - 60),
                      minWidth: 150),
                  child: ClipRRect(
                      borderRadius: const BorderRadius.all(Radius.circular(10)),
                      child: content));
            }),
          ),
        ),
        Visibility(
          visible:
              alignment == MainAxisAlignment.start && stateIcon != SizedBox,
          child: Align(
              alignment: Alignment.bottomCenter,
              child: Padding(
                padding: const EdgeInsets.only(right: 18.0),
                child: stateIcon,
              )),
        ),
      ],
    );
  }

  Widget _buildInlineVideoPlayer(String videoUri, bool preview) {
    // const double volume = kIsWeb ? 0.0 : 1.0;
    // controller.setVolume(volume);
    if (controller == null) {
      controller = VideoPlayerController.file(File(videoUri));
    } else {
      controller?.dispose();
      controller = VideoPlayerController.file(File(videoUri));
    }

    controller?.initialize();
    controller?.setLooping(false);
    // controller?.play();
    return Center(child: AspectRatioVideo(controller, preview));
  }

  @override
  void activate() {
    super.activate();
    controller?.play();
  }

  @override
  void deactivate() {
    controller?.pause();
    super.deactivate();
  }

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }
}