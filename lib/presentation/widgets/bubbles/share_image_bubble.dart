import 'dart:io';
import 'dart:math';

import 'package:androp/domain/androp_context.dart';
import 'package:androp/domain/concert/concert_provider.dart';
import 'package:androp/domain/device/device_manager.dart';
import 'package:androp/model/ui_bubble/shared_file.dart';
import 'package:androp/model/ui_bubble/ui_bubble.dart';
import 'package:androp/presentation/widgets/bubbles/accept_media_widget.dart';
import 'package:androp/presentation/widgets/bubbles/wait_to_accept_media_widget.dart';
import 'package:androp/presentation/widgets/segements/cancel_send_button.dart';
import 'package:androp/presentation/widgets/segements/resend_button.dart';
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

    final MainAxisAlignment alignment;
    if (entity.isFromMe(andropContext.deviceId)) {
      alignment = MainAxisAlignment.end;
    } else {
      alignment = MainAxisAlignment.start;
    }

    Widget stateIcon = const SizedBox(width: 48, height: 48,);
    final Widget content;
    if (entity.isFromMe(andropContext.deviceId)) {
      // 发送
      switch (sharedImage.state) {
        case FileState.picked:
          content =
              Image.file(key: _imageKey, File(sharedImage.content.path!!), fit: BoxFit.contain);
          stateIcon = CancelSendButton(key: _cancelSendButtonKey, entity: entity);
          break;
        case FileState.waitToAccepted:
          content = Stack(
            fit: StackFit.passthrough,
            children: [
              Image.file(key: _imageKey, File(sharedImage.content.path!!),
                  fit: BoxFit.contain),
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
          stateIcon = CancelSendButton(key: _cancelSendButtonKey, entity: entity);
          break;
        case FileState.inTransit:
          content = Stack(
            fit: StackFit.passthrough,
            children: [
              Image.file(key: _imageKey, File(sharedImage.content.path!!),
                  fit: BoxFit.contain),
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
          stateIcon = CancelSendButton(key: _cancelSendButtonKey, entity: entity);
          break;
        case FileState.sendCompleted:
        case FileState.receiveCompleted:
        case FileState.completed:
          content =
              Image.file(key: _imageKey, File(sharedImage.content.path!!), fit: BoxFit.contain);
          break;
        case FileState.cancelled:
        case FileState.sendFailed:
        case FileState.receiveFailed:
        case FileState.failed:
          content =
              Image.file(key: _imageKey, File(sharedImage.content.path!!), fit: BoxFit.contain);
          stateIcon = stateIcon = ResendButton(key: _resendButtonKey, entity: entity);
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
          content =
              Image.file(key: _imageKey, File(sharedImage.content.path!!), fit: BoxFit.contain);
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
      children: [
        Visibility(
          visible: alignment == MainAxisAlignment.end,
          child: Align(
              alignment: Alignment.bottomCenter,
              child: Padding(
                padding: const EdgeInsets.only(right: 18.0),
                child: stateIcon,
              )),
        ),
        // Expanded强制占用剩余的空间
        // Flexible默认允许子元素占用尽可能的剩余空间
        Flexible(
          child: DecoratedBox(
            decoration: BoxDecoration(
                color: backgroundColor,
                borderRadius: const BorderRadius.all(Radius.circular(10))),
            child: LayoutBuilder(
                builder: (BuildContext context, BoxConstraints constraints) {
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
                  child: ClipRRect(
                      borderRadius: const BorderRadius.all(Radius.circular(10)),
                      child: content));
            }),
          ),
        ),
        Visibility(
          visible:
              alignment == MainAxisAlignment.start,
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
}
