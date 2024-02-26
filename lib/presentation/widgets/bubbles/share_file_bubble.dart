
import 'dart:math';

import 'package:androp/domain/androp_context.dart';
import 'package:androp/domain/concert/concert_provider.dart';
import 'package:androp/model/ui_bubble/shared_file.dart';
import 'package:androp/model/ui_bubble/ui_bubble.dart';
import 'package:androp/utils/file/size_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';

class ShareFileBubble extends StatefulWidget {
  final UIBubble entity;

  const ShareFileBubble({super.key, required this.entity});

  @override
  State<StatefulWidget> createState() => ShareFileBubbleState();
}

class ShareFileBubbleState extends State<ShareFileBubble> {
  UIBubble get entity => widget.entity;

  @override
  void initState() {
    super.initState();

    // Thumbnailer.addCustomMimeTypesToIconDataMappings(<String, IconData>{
    //   'image/jpeg': Icons.image,
    // });
  }

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

    var showStateIcon = false;
    Widget stateIcon = SizedBox();
    final showProgressBar;
    final progressBarColor;
    final des;
    if (entity.isFromMe(andropContext.deviceId)) {
      switch (sharedFile.state) {
        case FileState.picked:
          showProgressBar = true;
          progressBarColor = Color.fromRGBO(0, 122, 255, 1);
          des = sharedFile.content.size.formateBinarySize();
          showStateIcon = true;
          stateIcon = IconButton(
              onPressed: () {
                concertProvider.cancel(entity);
              },
              icon: SvgPicture.asset(
                'assets/images/ic_cancel.svg',
              ));
          break;
        case FileState.waitToAccepted:
          showProgressBar = true;
          progressBarColor = Color.fromRGBO(0, 122, 255, 1);
          des = '${sharedFile.content.size.formateBinarySize()} · 等待对方确认';
          showStateIcon = true;
          stateIcon = IconButton(
              onPressed: () {
                concertProvider.cancel(entity);
              },
              icon: SvgPicture.asset(
                'assets/images/ic_cancel.svg',
              ));
          break;
          case FileState.inTransit:
          showProgressBar = true;
          progressBarColor = Color.fromRGBO(0, 122, 255, 1);
          des = sharedFile.content.size.formateBinarySize();
          showStateIcon = true;
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
          showProgressBar = false;
          progressBarColor = Color.fromRGBO(0, 122, 255, 1);
          des = '${sharedFile.content.size.formateBinarySize()} · 已发送';
          break;
        case FileState.sendFailed:
        case FileState.receiveFailed:
        case FileState.failed:
          des = '${sharedFile.content.size.formateBinarySize()} · 发送异常';
          showProgressBar = true;
          progressBarColor = const Color.fromRGBO(255, 59, 48, 1);
          showStateIcon = true;
          stateIcon = IconButton(
            onPressed: () {
              concertProvider.resend(entity);
            },
            icon: SvgPicture.asset(
              'assets/images/ic_trans_fail.svg',
            ),
          );
          break;
        case FileState.cancelled:
          des = '${sharedFile.content.size.formateBinarySize()} · 已取消';
          showProgressBar = true;
          progressBarColor = const Color.fromRGBO(255, 59, 48, 1);
          showStateIcon = true;
          stateIcon = IconButton(
            onPressed: () {
              concertProvider.resend(entity);
            },
            icon: SvgPicture.asset(
              'assets/images/ic_trans_fail.svg',
            ),
          );
          break;
        case FileState.unknown:
          throw StateError('Unknown send state: ${sharedFile.state}');
      }
    } else {
      switch (sharedFile.state) {
        case FileState.waitToAccepted:
          showProgressBar = true;
          progressBarColor = const Color.fromRGBO(0, 122, 255, 1);
          des = '${sharedFile.content.size.formateBinarySize()} · 点击接收';
          showStateIcon = true;
          stateIcon = SvgPicture.asset(
            'assets/images/ic_receive.svg',
          );
          break;
        case FileState.inTransit:
        case FileState.sendCompleted:
          showProgressBar = true;
          progressBarColor = const Color.fromRGBO(0, 122, 255, 1);
          des = sharedFile.content.size.formateBinarySize();
          break;
        case FileState.receiveCompleted:
        case FileState.completed:
          showProgressBar = false;
          progressBarColor = const Color.fromRGBO(0, 122, 255, 1);
          des = '${sharedFile.content.size.formateBinarySize()} · 已接收';
          break;
        case FileState.sendFailed:
        case FileState.receiveFailed:
        case FileState.failed:
          des = '${sharedFile.content.size.formateBinarySize()} · 接收失败';
          showProgressBar = true;
          progressBarColor = const Color.fromRGBO(255, 59, 48, 1);
          showStateIcon = true;
          stateIcon = SvgPicture.asset(
            'assets/images/ic_trans_fail.svg',
          );
          break;
        case FileState.cancelled:
          des = '${sharedFile.content.size.formateBinarySize()} · 已取消';
          showProgressBar = true;
          progressBarColor = const Color.fromRGBO(255, 59, 48, 1);
          showStateIcon = true;
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
      decoration: const BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.all(Radius.circular(10))),
      child: LayoutBuilder(
        builder: (context, constraints) {
          return ConstrainedBox(
            constraints: BoxConstraints(
                maxWidth: max(constraints.maxWidth - 60, 200)),
            child: Padding(
              padding: const EdgeInsets.only(
                  left: 10, top: 10, right: 10, bottom: 10),
              child: IntrinsicWidth(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.center,
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
                            width: 16,
                          ),
                          Container(
                            width: 44,
                            height: 44,
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(6),
                                color:
                                const Color.fromRGBO(0, 122, 255, 1)),
                            alignment: Alignment.center,
                            child: SvgPicture.asset(
                                'assets/images/ic_file1.svg'),
                          )
                        ]),
                    Visibility(
                        visible: sharedFile.content.size >= 0,
                        child: Padding(
                          padding: const EdgeInsets.only(top: 8.0),
                          child: Text(
                            des,
                            style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w400,
                                color: contentColor.withOpacity(0.5)),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        )),
                    Visibility(
                      visible: showProgressBar,
                      child: Padding(
                        padding: const EdgeInsets.only(top: 10.0),
                        child: LinearProgressIndicator(
                            value: sharedFile.progress,
                            minHeight: 6,
                            borderRadius: BorderRadius.circular(6),
                            backgroundColor:
                            const Color.fromRGBO(247, 247, 247, 1),
                            color: progressBarColor),
                      ),
                    )
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
    Widget innerBubble;
    if (!entity.isFromMe(andropContext.deviceId) && sharedFile.state == FileState.waitToAccepted)  {
      innerBubble = InkWell(onTap: () {
        concertProvider.confirmReceive(entity);
      }, child: _innerBubble,);
    } else {
      innerBubble = _innerBubble;
    }

    return Row(
      mainAxisAlignment: alignment,
      children: [
        Visibility(
            visible: alignment == MainAxisAlignment.end && showStateIcon,
            child: Padding(
              padding: const EdgeInsets.only(right: 18.0),
              child: stateIcon,
            )),
        Flexible(
          child: innerBubble,
        ),
        Visibility(
            visible: alignment == MainAxisAlignment.start && showStateIcon,
            child: Padding(
              padding: const EdgeInsets.only(left: 18.0),
              child: stateIcon,
            )),
      ],
    );
  }
}