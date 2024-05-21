import 'dart:math';

import 'package:flix/domain/androp_context.dart';
import 'package:flix/domain/concert/concert_provider.dart';
import 'package:flix/domain/log/flix_log.dart';
import 'package:flix/model/ui_bubble/shared_file.dart';
import 'package:flix/presentation/basic/flix_thumbnail_provider.dart';
import 'package:flix/presentation/screens/base_screen.dart';
import 'package:flix/presentation/widgets/bubbles/accept_media_widget.dart';
import 'package:flix/presentation/widgets/bubbles/base_file_bubble.dart';
import 'package:flix/presentation/widgets/bubbles/bubble_decoration_widget.dart';
import 'package:flix/presentation/widgets/bubbles/wait_to_accept_media_widget.dart';
import 'package:flix/presentation/widgets/segements/file_bubble_interaction.dart';
import 'package:flix/presentation/widgets/segements/preview_error_widget.dart';
import 'package:flix/utils/platform_utils.dart';
import 'package:flix/utils/text/text_extension.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ShareImageBubble extends BaseFileBubble {
  const ShareImageBubble({super.key, required super.entity});

  @override
  State<ShareImageBubble> createState() => ShareImageBubbleState();
}

class ShareImageBubbleState extends BaseFileBubbleState<ShareImageBubble> {
  final _imageKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    AndropContext andropContext = context.watch();
    ConcertProvider concertProvider = context.watch();
    final sharedImage = entity.shareable as SharedFile;
    const Color backgroundColor = Colors.white;
    bool clickable = false;
    final Widget Function(int? cacheWidth, int? cacheHeight) content;
    if (entity.isFromMe(andropContext.deviceId)) {
      // 发送
      switch (sharedImage.state) {
        case FileState.picked:
          clickable = true;
          content = (cacheWidth, cacheHeight) => _normalContent(sharedImage, cacheWidth, cacheHeight);
          break;
        case FileState.waitToAccepted:
          clickable = false;
          content = (_w, _h) => _waitToAcceptedContent(sharedImage, _w, _h);
          break;
        case FileState.inTransit:
          clickable = false;

          content = (_w, _h) => _inTransContent(sharedImage, _w, _h);
          break;
        case FileState.sendCompleted:
        case FileState.receiveCompleted:
        case FileState.completed:
          clickable = true;
          content = (cacheWidth, cacheHeight) => _normalContent(sharedImage, cacheWidth, cacheHeight);
          break;
        case FileState.cancelled:
        case FileState.sendFailed:
        case FileState.receiveFailed:
        case FileState.failed:
          clickable = true;
          content = (cacheWidth, cacheHeight) => _normalContent(sharedImage, cacheWidth, cacheHeight);
          break;
        default:
          throw StateError('Error send state: ${sharedImage.state}');
      }
    } else {
      // 接收
      switch (sharedImage.state) {
        case FileState.waitToAccepted:
          content = (_w, _h) => InkWell(
                onTap: () {
                  _confirmReceive(concertProvider);
                },
                child: AcceptMediaWidget(),
              );
        case FileState.inTransit:
        case FileState.sendCompleted:
          content = (_w, _h) => _inReceiveContent(sharedImage);
          break;
        case FileState.receiveCompleted:
        case FileState.completed:
          clickable = true;
          content = (cacheWidth, cacheHeight) => _image(false, sharedImage,
              cacheWidth: cacheWidth, cacheHeight: cacheHeight);
          break;
        case FileState.cancelled:
        case FileState.sendFailed:
        case FileState.receiveFailed:
        case FileState.failed:
          content = (_w, _h) => _receiveErrorContent();
          break;
        default:
          throw StateError('Error receive state: ${sharedImage.state}');
      }
    }

    return BubbleDecorationWidget(
      key: ValueKey(entity.shareable.id),
      entity: entity,
      child: FileBubbleInteraction(
        key: ValueKey(entity.shareable.id),
        bubble: entity,
        filePath: sharedImage.content.path ?? '',
        clickable: clickable,
        child: _buildAspectContent(backgroundColor, sharedImage, content),
      ),
    );
  }

  AspectRatio _receiveErrorContent() {
    return AspectRatio(
              aspectRatio: 1.333333,
              child: DecoratedBox(
                decoration: const BoxDecoration(color: Colors.white),
                child: _imageErrorWidget(),
              ),
            );
  }

  AspectRatio _inReceiveContent(SharedFile sharedImage) {
    return AspectRatio(
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
                            fontWeight: FontWeight.normal).fix())
                  ],
                ),
              ),
            );
  }

  Widget _normalContent(SharedFile sharedImage, int? cacheWidth, int? cacheHeight) {
    return _image(true, sharedImage,
            cacheWidth: cacheWidth, cacheHeight: cacheHeight);
  }

  Stack _waitToAcceptedContent(SharedFile sharedImage, int? _w, int? _h) {
    return Stack(
              fit: StackFit.passthrough,
              children: [
                _normalContent(sharedImage, _w, _h),
                Container(
                  decoration: const BoxDecoration(
                      color: Color.fromRGBO(0, 0, 0, 0.5)),
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
  }

  Stack _inTransContent(SharedFile sharedImage, int? _w, int? _h) {
    return Stack(
              fit: StackFit.passthrough,
              children: [
                _normalContent(sharedImage, _w, _h),
                Container(
                  decoration: const BoxDecoration(
                      color: Color.fromRGBO(0, 0, 0, 0.5)),
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
                                fontWeight: FontWeight.normal)
                            .fix(),
                      )
                    ],
                  ),
                )
              ],
            );
  }

  DecoratedBox _buildAspectContent(Color backgroundColor, SharedFile sharedImage, Widget Function(int? cacheWidth, int? cacheHeight) content) {
    return DecoratedBox(
        decoration: BoxDecoration(color: backgroundColor),
        child: LayoutBuilder(
            builder: (BuildContext context, BoxConstraints constraints) {
          final maxPhysicalSize = 250.0;
          // Platform.isAndroid || Platform.isIOS ? 250.0 : 300.0;

          if (sharedImage.content.width == 0 ||
              sharedImage.content.height == 0) {
            return ConstrainedBox(
                constraints: BoxConstraints(
                    minWidth: 100,
                    maxWidth: max(100,
                        min(constraints.maxWidth - 60, maxPhysicalSize)),
                    minHeight: 100,
                    maxHeight: maxPhysicalSize),
                child: IntrinsicHeight(child: content(null, null)));
          } else {
            return _aspectContent(maxPhysicalSize, constraints, context, sharedImage, content);
          }
        }),
      );
  }

  SizedBox _aspectContent(double maxPhysicalSize, BoxConstraints constraints, BuildContext context, SharedFile sharedImage, Widget content(int? cacheWidth, int? cacheHeight)) {
    double width;
    double height;

    const minSize = 100;
    final maxSize = max(
        minSize, min(maxPhysicalSize, constraints.maxWidth - 60));

    final dpi = MediaQuery.of(context).devicePixelRatio;
    final imageOriginWidth = sharedImage.content.width / dpi;
    final imageOriginHeight = sharedImage.content.height / dpi;
    if (imageOriginWidth >= imageOriginHeight) {
      if (imageOriginWidth > maxSize) {
        width = maxSize * 1.0;
      } else if (imageOriginWidth < minSize) {
        width = minSize * 1.0;
      } else {
        width = imageOriginWidth;
      }
      height = width / imageOriginWidth * imageOriginHeight;
    } else {
      if (imageOriginHeight > maxSize) {
        height = maxSize * 1.0;
      } else if (imageOriginHeight < minSize) {
        height = minSize * 1.0;
      } else {
        height = imageOriginHeight;
      }
      width = height / imageOriginHeight * imageOriginWidth;
    }

    return SizedBox(
        width: width * 1.0,
        height: height * 1.0,
        child: content(
            (width * dpi).toInt(), (height * dpi).toInt()));
  }

  void _confirmReceive(ConcertProvider concertProvider) async {
    if (await checkStoragePermission(context)) {
      concertProvider.confirmReceive(entity);
    }
  }

  Widget _image(bool isFromSelf, SharedFile sharedFile,
      {int? cacheWidth, int? cacheHeight}) {
    final resourceId = sharedFile.content.resourceId;
    errorBuilder(
      BuildContext context,
      Object error,
      StackTrace? stackTrace,
    ) {
      talker.error(
          'failed to preview image: ${entity.shareable.id}, ${sharedFile.content.path}',
          error,
          stackTrace);
      return _imageErrorWidget();
    }
    return Image(
      key: _imageKey,
      image: FlixThumbnailProvider(
          id: sharedFile.id,
          resourceId: resourceId.isEmpty || isDesktop()
              ? null
              : sharedFile.content.resourceId,
          resourcePath: sharedFile.content.path,
          preferWidth: cacheWidth ?? 250,
          preferHeight: cacheHeight ?? 250),
      fit: BoxFit.contain,
      errorBuilder: errorBuilder,
    );
  }

  Widget _imageErrorWidget() => PreviewErrorWidget();
}
