import 'dart:io';
import 'dart:math';

import 'package:androp/model/ui_bubble/shared_file.dart';
import 'package:androp/model/ui_bubble/ui_bubble.dart';
import 'package:androp/model/shareable.dart';
import 'package:androp/presentation/widgets/app_icon.dart';
import 'package:androp/presentation/widgets/aspect_ratio_video.dart';
import 'package:androp/utils/file/size_utils.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
// import 'package:thumbnailer/thumbnailer.dart';
import 'package:video_player/video_player.dart';

import '../../domain/androp_context.dart';

class ShareBubble extends StatelessWidget {
  final UIBubble entity;

  const ShareBubble({super.key, required this.entity});

  @override
  Widget build(BuildContext context) {
    if (entity.shareable is SharedText) {
      return ShareTextBubble(entity: entity);
    } else if (entity.shareable is SharedImage) {
      return ShareImageBubble(entity: entity);
    } else if (entity.shareable is SharedVideo) {
      return ShareVideoBubble(entity: entity);
    } else if (entity.shareable is SharedApp) {
      return ShareAppBubble(entity: entity);
    } else if (entity.shareable is SharedFile) {
      return ShareFileBubble(entity: entity);
    } else {
      return const Placeholder();
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
    if (entity.from == andropContext.deviceId) {
      backgroundColor = const Color.fromRGBO(0, 122, 255, 1);
    } else {
      backgroundColor = Colors.white;
    }

    final Color contentColor;
    if (entity.from == andropContext.deviceId) {
      contentColor = Colors.white;
    } else {
      contentColor = Colors.black;
    }

    final Alignment alignment;
    if (entity.from == andropContext.deviceId) {
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
    final SharedImage sharedImage = entity.shareable as SharedImage;
    final Color backgroundColor;
    if (entity.from == andropContext.deviceId) {
      backgroundColor = const Color.fromRGBO(0, 122, 255, 1);
    } else {
      backgroundColor = Colors.white;
    }

    if (entity.from == andropContext.deviceId) {
    } else {}

    final Alignment alignment;
    if (entity.from == andropContext.deviceId) {
      alignment = Alignment.centerRight;
    } else {
      alignment = Alignment.centerLeft;
    }

    final Widget content;
    if (sharedImage.content.path == null) {
      content = const Text("接收中");
    } else {
      content = ClipRRect(
          borderRadius: const BorderRadius.all(Radius.circular(10)),
          child: Image.file(File(sharedImage.content.path!!),
              fit: BoxFit.contain));
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
                  maxWidth: max(150, constraints.maxWidth - 60), minWidth: 150),
              child: content);
        }),
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
    final SharedVideo sharedVideo = entity.shareable as SharedVideo;
    final Color backgroundColor;
    if (entity.from == andropContext.deviceId) {
      backgroundColor = const Color.fromRGBO(0, 122, 255, 1);
    } else {
      backgroundColor = Colors.white;
    }

    if (entity.from == andropContext.deviceId) {
    } else {}

    final Alignment alignment;
    if (entity.from == andropContext.deviceId) {
      alignment = Alignment.centerRight;
    } else {
      alignment = Alignment.centerLeft;
    }
    final Widget videoWidget;
    if (sharedVideo.content.path == null) {
      videoWidget = Text("接收中视频中");
    } else {
      videoWidget = _buildInlineVideoPlayer(sharedVideo.content.path!);
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
                  maxWidth: max(150, constraints.maxWidth - 60), minWidth: 150),
              child: ClipRRect(
                  borderRadius: const BorderRadius.all(Radius.circular(10)),
                  child: videoWidget));
        }),
      ),
    );
  }

  Widget _buildInlineVideoPlayer(String videoUri) {
    // const double volume = kIsWeb ? 0.0 : 1.0;
    // controller.setVolume(volume);
    if (controller == null) {
      controller = VideoPlayerController.file(File(videoUri));
    } else {
      controller?.dispose();
      controller = VideoPlayerController.file(File(videoUri));
    }

    controller?.initialize();
    controller?.setLooping(true);
    controller?.play();
    return Center(child: AspectRatioVideo(controller));
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
    if (entity.from == andropContext.deviceId) {
      backgroundColor = const Color.fromRGBO(0, 122, 255, 1);
    } else {
      backgroundColor = Colors.white;
    }

    final Color contentColor;
    if (entity.from == andropContext.deviceId) {
      contentColor = Colors.white;
    } else {
      contentColor = Colors.black;
    }

    final Alignment alignment;
    if (entity.from == andropContext.deviceId) {
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
    if (entity.from == andropContext.deviceId) {
      backgroundColor = const Color.fromRGBO(0, 122, 255, 1);
    } else {
      backgroundColor = Colors.white;
    }

    final Color contentColor;
    if (entity.from == andropContext.deviceId) {
      contentColor = Colors.white;
    } else {
      contentColor = Colors.black;
    }

    final Color thumbnailBackgroundColor;
    if (entity.from == andropContext.deviceId) {
      thumbnailBackgroundColor = Colors.white;
    } else {
      thumbnailBackgroundColor = const Color.fromRGBO(0, 122, 255, 1);
    }

    final Color thumbnailColor;
    if (entity.from == andropContext.deviceId) {
      thumbnailColor = const Color.fromRGBO(0, 122, 255, 1);
    } else {
      thumbnailColor = Colors.white;
    }

    final Alignment alignment;
    if (entity.from == andropContext.deviceId) {
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
                              sharedFile.meta.name,
                              style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w400,
                                  color: contentColor),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            Visibility(
                                visible: sharedFile.meta.size > 0,
                                child: Text(
                                  sharedFile.meta.size.formateBinarySize(),
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
