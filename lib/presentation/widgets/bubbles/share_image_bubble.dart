import 'dart:io';
import 'dart:math';

import 'package:flix/domain/androp_context.dart';
import 'package:flix/domain/concert/concert_provider.dart';
import 'package:flix/domain/device/device_manager.dart';
import 'package:flix/model/ui_bubble/shared_file.dart';
import 'package:flix/model/ui_bubble/ui_bubble.dart';
import 'package:flix/presentation/widgets/bubbles/accept_media_widget.dart';
import 'package:flix/presentation/widgets/bubbles/wait_to_accept_media_widget.dart';
import 'package:flix/presentation/widgets/segements/cancel_send_button.dart';
import 'package:flix/presentation/widgets/segements/file_bubble_interaction.dart';
import 'package:flix/presentation/widgets/segements/resend_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';

class ShareImageBubble extends StatefulWidget {
  final UIBubble entity;

  const ShareImageBubble({super.key, required this.entity});

  @override
  State<StatefulWidget> createState() => ShareImageBubbleState();
}

class ShareImageBubbleState extends State<ShareImageBubble> {
  UIBubble get entity => widget.entity;

  final _imageKey = GlobalKey();
  final _cancelSendButtonKey = GlobalKey();
  final _resendButtonKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    final sharedImage = entity.shareable as SharedFile;
    if (entity.isFromMe(DeviceManager.instance.did) && Platform.isMacOS) {
      sharedImage.content.startAccessPath();
    }
  }

  @override
  void dispose() {
    final sharedImage = entity.shareable as SharedFile;
    if (entity.isFromMe(DeviceManager.instance.did) && Platform.isMacOS) {
      sharedImage.content.stopAccessPath();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    AndropContext andropContext = context.watch();
    ConcertProvider concertProvider = context.watch();
    final sharedImage = entity.shareable as SharedFile;
    final Color backgroundColor;
    if (entity.isFromMe(andropContext.deviceId)) {
      backgroundColor = const Color.fromRGBO(0, 122, 255, 1);
    } else {
      backgroundColor = Colors.white;
    }

    bool clickable = false;
    final MainAxisAlignment alignment;
    if (entity.isFromMe(andropContext.deviceId)) {
      alignment = MainAxisAlignment.end;
    } else {
      alignment = MainAxisAlignment.start;
    }

    Widget stateIcon = const SizedBox(
      width: 20,
      height: 20,
    );
    final Widget content;
    if (entity.isFromMe(andropContext.deviceId)) {
      // 发送
      switch (sharedImage.state) {
        case FileState.picked:
          clickable = true;
          content = _image(sharedImage);
          stateIcon =
              CancelSendButton(key: _cancelSendButtonKey, entity: entity);
          break;
        case FileState.waitToAccepted:
          clickable = false;

          content = Stack(
            fit: StackFit.passthrough,
            children: [
              _image(sharedImage),
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
          stateIcon =
              CancelSendButton(key: _cancelSendButtonKey, entity: entity);
          break;
        case FileState.inTransit:
          clickable = false;

          content = Stack(
            fit: StackFit.passthrough,
            children: [
              _image(sharedImage),
              Container(
                decoration:
                    const BoxDecoration(color: Color.fromRGBO(0, 0, 0, 0.5)),
                width: double.infinity,
                height: double.infinity,
                child: const SizedBox(),
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
                      '${(sharedImage.progress * 100).round()}%',
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
          stateIcon =
              CancelSendButton(key: _cancelSendButtonKey, entity: entity);
          break;
        case FileState.sendCompleted:
        case FileState.receiveCompleted:
        case FileState.completed:
          clickable = true;
          content = _image(sharedImage);
          break;
        case FileState.cancelled:
        case FileState.sendFailed:
        case FileState.receiveFailed:
        case FileState.failed:
          clickable = true;
          content = _image(sharedImage);
          stateIcon =
              stateIcon = ResendButton(key: _resendButtonKey, entity: entity);
          break;
        default:
          throw StateError('Error send state: ${sharedImage.state}');
      }
    } else {
      // 接收
      switch (sharedImage.state) {
        case FileState.waitToAccepted:
          content = InkWell(
            onTap: () {
              concertProvider.confirmReceive(entity);
            },
            child: AcceptMediaWidget(),
          );
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
                  const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        backgroundColor: Colors.transparent,
                        color: Colors.white,
                        strokeWidth: 2.0,
                      )),
                  Text('${(sharedImage.progress * 100).round()}%',
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.normal))
                ],
              ),
            ),
          );
          break;
        case FileState.receiveCompleted:
        case FileState.completed:
          clickable = true;
          content = _image(sharedImage);
          break;
        case FileState.cancelled:
        case FileState.sendFailed:
        case FileState.receiveFailed:
        case FileState.failed:
          content = AspectRatio(
            aspectRatio: 1.333333,
            child: DecoratedBox(
              decoration:
                  const BoxDecoration(color: Color.fromRGBO(0, 0, 0, 0.5)),
            ),
          );
          stateIcon = SvgPicture.asset('assets/images/ic_trans_fail.svg');
          break;
        default:
          throw StateError('Error receive state: ${sharedImage.state}');
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
          child: FileBubbleInteraction(
            filePath: sharedImage.content.path ?? '',
            clickable: clickable,
            child: ClipRRect(
                borderRadius: const BorderRadius.all(Radius.circular(10)),
                child: DecoratedBox(
                  decoration: BoxDecoration(
                      color: backgroundColor,
                      borderRadius: const BorderRadius.all(Radius.circular(10))),
                  child: LayoutBuilder(builder:
                      (BuildContext context, BoxConstraints constraints) {
                    if (sharedImage.content.width == 0) {
                      return ConstrainedBox(
                          constraints: BoxConstraints(
                              minWidth: 150,
                              maxWidth:
                                  max(150, min(constraints.maxWidth - 60, 300)),
                              minHeight: 150),
                          child: IntrinsicHeight(child: content));
                    } else {
                      final width;
                      if (sharedImage.content.width >
                          max(150, min(300, constraints.maxWidth - 60))) {
                        width = max(150, min(300, constraints.maxWidth - 60));
                      } else if (sharedImage.content.width < 150) {
                        width = 150;
                      } else {
                        width = sharedImage.content.width;
                      }
                      final height;

                      if (sharedImage.content.width == 0) {
                        height = width;
                      } else {
                        height = sharedImage.content.height *
                            1.0 /
                            sharedImage.content.width *
                            width;
                      }
                      return SizedBox(
                          width: width * 1.0,
                          height: height * 1.0,
                          child: content);
                    }
                  }),
                )),
          ),
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

  Widget _image(SharedFile sharedFile) {
    return Image.file(
        key: _imageKey, File(sharedFile.content.path!!), fit: BoxFit.contain);
  }
}
