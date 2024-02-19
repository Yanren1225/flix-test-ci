import 'dart:io';
import 'dart:math';

import 'package:androp/model/ship/primitive_bubble.dart';
import 'package:androp/model/ui_bubble/shared_file.dart';
import 'package:androp/model/ui_bubble/ui_bubble.dart';
import 'package:androp/model/ui_bubble/shareable.dart';
import 'package:androp/presentation/widgets/app_icon.dart';
import 'package:androp/presentation/widgets/aspect_ratio_video.dart';
import 'package:androp/utils/file/size_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:provider/provider.dart';

// import 'package:thumbnailer/thumbnailer.dart';
import 'package:video_player/video_player.dart';

import '../../domain/androp_context.dart';

class ShareBubble extends StatelessWidget {
  final UIBubble uiBubble;

  const ShareBubble({super.key, required this.uiBubble});

  @override
  Widget build(BuildContext context) {
    switch (uiBubble.type) {
      case BubbleType.Text:
        return ShareTextBubble(entity: uiBubble);
      case BubbleType.Image:
        return ShareImageBubble(entity: uiBubble);
      case BubbleType.Video:
        return ShareVideoBubble(entity: uiBubble);
      case BubbleType.File:
        return ShareFileBubble(entity: uiBubble);
      case BubbleType.App:
        return ShareAppBubble(entity: uiBubble);
    }
  }
}

class ShareTextBubble extends StatelessWidget {
  final UIBubble entity;

  const ShareTextBubble({super.key, required this.entity});

  @override
  Widget build(BuildContext context) {
    AndropContext andropContext = context.watch();
    final SharedText sharedText = entity.shareable as SharedText;
    final Color backgroundColor;
    if (entity.isFromMe(andropContext.deviceId)) {
      backgroundColor = const Color.fromRGBO(0, 122, 255, 1);
    } else {
      backgroundColor = Colors.white;
    }

    final Color contentColor;
    if (entity.isFromMe(andropContext.deviceId)) {
      contentColor = Colors.white;
    } else {
      contentColor = Colors.black;
    }

    final Alignment alignment;
    if (entity.isFromMe(andropContext.deviceId)) {
      alignment = Alignment.centerRight;
    } else {
      alignment = Alignment.centerLeft;
    }
    return Align(
      alignment: alignment,
      child: Container(
        decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: const BorderRadius.all(Radius.circular(10))),
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Text(
            sharedText.content,
            style: TextStyle(
                color: contentColor, fontSize: 14, fontWeight: FontWeight.w500),
          ),
        ),
      ),
    );
  }
}

class ShareImageBubble extends StatelessWidget {
  final UIBubble entity;

  const ShareImageBubble({super.key, required this.entity});

  @override
  Widget build(BuildContext context) {
    AndropContext andropContext = context.watch();
    final sharedImage = entity.shareable as SharedFile;
    final Color backgroundColor;
    if (entity.isFromMe(andropContext.deviceId)) {
      backgroundColor = const Color.fromRGBO(0, 122, 255, 1);
    } else {
      backgroundColor = Colors.white;
    }

    final Alignment alignment;
    final MainAxisAlignment mainAxisAlignment;
    if (entity.isFromMe(andropContext.deviceId)) {
      alignment = Alignment.centerRight;
      mainAxisAlignment = MainAxisAlignment.end;
    } else {
      alignment = Alignment.centerLeft;
      mainAxisAlignment = MainAxisAlignment.start;
    }

    Widget stateIcon = const SizedBox();
    final Widget content;
    if (entity.isFromMe(andropContext.deviceId)) {
      // 发送
      switch (sharedImage.state) {
        case FileState.picked:
        case FileState.waitToAccepted:
        case FileState.inTransit:
          content = IntrinsicHeight(
            child: Stack(
              fit: StackFit.passthrough,
              children: [
                Image.file(File(sharedImage.content.path!!),
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
            ),
          );
          stateIcon = IconButton(
              onPressed: () {
                // TODO 取消发送
              },
              icon: SvgPicture.asset(
                'assets/images/ic_cancel.svg',
              ));
          break;
        case FileState.sendCompleted:
        case FileState.receiveCompleted:
        case FileState.completed:
          content =
              Image.file(File(sharedImage.content.path!!), fit: BoxFit.contain);
          break;
        case FileState.cancelled:
        case FileState.sendFailed:
        case FileState.receiveFailed:
        case FileState.failed:
          content =
              Image.file(File(sharedImage.content.path!!), fit: BoxFit.contain);
          stateIcon = SvgPicture.asset('assets/images/ic_trans_fail.svg');
          break;
        default:
          throw StateError('Error send state: ${sharedImage.state}');
      }
    } else {
      // 接收
      switch (sharedImage.state) {
        case FileState.waitToAccepted:
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
              Image.file(File(sharedImage.content.path!!), fit: BoxFit.contain);
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
    return Align(
      alignment: alignment,
      child: Row(
        mainAxisAlignment: mainAxisAlignment,
        children: [
          Align(alignment: Alignment.bottomCenter, child: stateIcon),
          const SizedBox(
            width: 18,
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
                return ConstrainedBox(
                    constraints: BoxConstraints(
                        maxWidth: min(300, constraints.maxWidth - 60),
                        minWidth: 150),
                    child: ClipRRect(
                        borderRadius:
                            const BorderRadius.all(Radius.circular(10)),
                        child: content));
              }),
            ),
          ),
        ],
      ),
    );
  }
}

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
    final sharedVideo = entity.shareable as SharedFile;
    final Color backgroundColor;
    if (entity.isFromMe(andropContext.deviceId)) {
      backgroundColor = const Color.fromRGBO(0, 122, 255, 1);
    } else {
      backgroundColor = Colors.white;
    }

    if (entity.isFromMe(andropContext.deviceId)) {
    } else {}

    final Alignment alignment;
    if (entity.isFromMe(andropContext.deviceId)) {
      alignment = Alignment.centerRight;
    } else {
      alignment = Alignment.centerLeft;
    }

    Widget stateIcon = SizedBox();
    final Widget content;
    if (entity.isFromMe(andropContext.deviceId)) {
      // 发送
      switch (sharedVideo.state) {
        case FileState.picked:
        case FileState.waitToAccepted:
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
                // TODO 取消发送
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
          stateIcon = SvgPicture.asset('assets/images/ic_trans_fail.svg');
          break;
        default:
          throw StateError('Error send state: ${sharedVideo.state}');
      }
    } else {
      // 接收
      switch (sharedVideo.state) {
        case FileState.waitToAccepted:
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
              decoration:
              BoxDecoration(color: Color.fromRGBO(0, 0, 0, 0.5)),
            ),
          );
          stateIcon = SvgPicture.asset('assets/images/ic_trans_fail.svg');
          break;
        default:
          throw StateError('Error receive state: ${sharedVideo.state}');
      }
    }
    return Align(
      alignment: alignment,
      child: Container(
        decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: const BorderRadius.all(Radius.circular(10))),
        child: LayoutBuilder(
            builder: (BuildContext context, BoxConstraints constraints) {
          return ConstrainedBox(
              constraints: BoxConstraints(
                  maxWidth: min(300, constraints.maxWidth - 60), minWidth: 150),
              child: ClipRRect(
                  borderRadius: const BorderRadius.all(Radius.circular(10)),
                  child: content));
        }),
      ),
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

class ShareAppBubble extends StatelessWidget {
  final UIBubble entity;

  const ShareAppBubble({super.key, required this.entity});

  @override
  Widget build(BuildContext context) {
    AndropContext andropContext = context.watch();
    final SharedApp sharedApp = entity.shareable as SharedApp;
    final Color backgroundColor;
    if (entity.isFromMe(andropContext.deviceId)) {
      backgroundColor = const Color.fromRGBO(0, 122, 255, 1);
    } else {
      backgroundColor = Colors.white;
    }

    final Color contentColor;
    if (entity.isFromMe(andropContext.deviceId)) {
      contentColor = Colors.white;
    } else {
      contentColor = Colors.black;
    }

    final Alignment alignment;
    if (entity.isFromMe(andropContext.deviceId)) {
      alignment = Alignment.centerRight;
    } else {
      alignment = Alignment.centerLeft;
    }
    return Align(
      alignment: alignment,
      child: Container(
        decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: const BorderRadius.all(Radius.circular(10))),
        child: LayoutBuilder(
          builder: (context, constraints) {
            return ConstrainedBox(
              constraints: BoxConstraints(maxWidth: constraints.maxWidth - 60),
              child: Padding(
                padding: const EdgeInsets.only(
                    left: 16, top: 12, right: 16, bottom: 12),
                child: Row(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Image(
                        image: AppIcon(app: sharedApp.content),
                        width: 50,
                        height: 50,
                      ),
                      const SizedBox(
                        width: 16,
                      ),
                      Flexible(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              sharedApp.content.appName,
                              style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w400,
                                  color: contentColor),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            Text(
                              sharedApp.content.packageName,
                              style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w400,
                                  color: contentColor.withOpacity(0.5)),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            )
                          ],
                        ),
                      ),
                    ]),
              ),
            );
          },
        ),
      ),
    );
  }
}

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
    final SharedFile sharedFile = entity.shareable as SharedFile;
    final Color backgroundColor;
    if (entity.isFromMe(andropContext.deviceId)) {
      backgroundColor = const Color.fromRGBO(0, 122, 255, 1);
    } else {
      backgroundColor = Colors.white;
    }

    final Color contentColor;
    if (entity.isFromMe(andropContext.deviceId)) {
      contentColor = Colors.white;
    } else {
      contentColor = Colors.black;
    }

    final Color thumbnailBackgroundColor;
    if (entity.isFromMe(andropContext.deviceId)) {
      thumbnailBackgroundColor = Colors.white;
    } else {
      thumbnailBackgroundColor = const Color.fromRGBO(0, 122, 255, 1);
    }

    final Color thumbnailColor;
    if (entity.isFromMe(andropContext.deviceId)) {
      thumbnailColor = const Color.fromRGBO(0, 122, 255, 1);
    } else {
      thumbnailColor = Colors.white;
    }

    final Alignment alignment;
    if (entity.isFromMe(andropContext.deviceId)) {
      alignment = Alignment.centerRight;
    } else {
      alignment = Alignment.centerLeft;
    }
    return Align(
      alignment: alignment,
      child: Container(
        decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: const BorderRadius.all(Radius.circular(10))),
        child: LayoutBuilder(
          builder: (context, constraints) {
            return ConstrainedBox(
              constraints: BoxConstraints(maxWidth: constraints.maxWidth - 60),
              child: Padding(
                padding: const EdgeInsets.only(
                    left: 16, top: 12, right: 16, bottom: 12),
                child: Row(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // Thumbnail(
                      //     errorBuilder: (uildContext, Exception error) {
                      //       return Container(
                      //         height: 200,
                      //         color: Colors.blue,
                      //         child: const Center(
                      //           child: Text('Cannot load file contents'),
                      //         ),
                      //       );
                      //     },
                      //     dataResolver: () async {
                      //       throw Error();
                      //     },
                      //     mimeType: sharedFile.content.mimeType ?? "unknown",
                      //     // mimeType: 'text/html',
                      //     widgetSize: 50,
                      //     onlyIcon: true,
                      //     decoration: WidgetDecoration(
                      //       backgroundColor: thumbnailBackgroundColor,
                      //       iconColor: thumbnailColor,
                      //     )),
                      // const SizedBox(
                      //   width: 16,
                      // ),
                      Flexible(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              sharedFile.content.name,
                              style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w400,
                                  color: contentColor),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            Visibility(
                                visible: sharedFile.content.size > 0,
                                child: Text(
                                  sharedFile.content.size.formateBinarySize(),
                                  style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w400,
                                      color: contentColor.withOpacity(0.5)),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ))
                          ],
                        ),
                      ),
                    ]),
              ),
            );
          },
        ),
      ),
    );
  }
}
