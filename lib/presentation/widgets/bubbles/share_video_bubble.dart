import 'dart:io';
import 'dart:math';

import 'package:flix/presentation/widgets/bubbles/bubble_decoration_widget.dart';
import 'package:flix/presentation/widgets/bubbles/trans_info_widget.dart';
import 'package:flix/utils/text/text_extension.dart';
import 'package:flix/domain/androp_context.dart';
import 'package:flix/domain/concert/concert_provider.dart';
import 'package:flix/domain/log/flix_log.dart';
import 'package:flix/model/ui_bubble/shared_file.dart';
import 'package:flix/presentation/basic/flix_thumbnail_provider.dart';
import 'package:flix/presentation/screens/base_screen.dart';
import 'package:flix/presentation/widgets/aspect_ratio_video.dart';
import 'package:flix/presentation/widgets/bubbles/accept_media_widget.dart';
import 'package:flix/presentation/widgets/bubbles/base_file_bubble.dart';
import 'package:flix/presentation/widgets/bubbles/wait_to_accept_media_widget.dart';
import 'package:flix/presentation/widgets/segements/cancel_send_button.dart';
import 'package:flix/presentation/widgets/segements/file_bubble_interaction.dart';
import 'package:flix/presentation/widgets/segements/preview_error_widget.dart';
import 'package:flix/presentation/widgets/segements/resend_button.dart';
import 'package:flix/utils/platform_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import 'package:video_player/video_player.dart';

class ShareVideoBubble extends BaseFileBubble {
  const ShareVideoBubble({super.key, required super.entity});

  @override
  State<StatefulWidget> createState() => ShareVideoBubbleState();
}

class ShareVideoBubbleState extends BaseFileBubbleState<ShareVideoBubble> {
  VideoPlayerController? controller;

  final _cancelButtonKey = GlobalKey();
  final _resendButtonKey = GlobalKey();
  final _videoWidget = GlobalKey();

  @override
  Widget build(BuildContext context) {
    AndropContext andropContext = context.watch();
    ConcertProvider concertProvider = context.watch();
    final sharedVideo = entity.shareable as SharedFile;
    talker.debug('video with path: ${sharedVideo.content.path}');

    final Color backgroundColor;
    // if (entity.isFromMe(andropContext.deviceId)) {
    //   backgroundColor = const Color.fromRGBO(0, 122, 255, 1);
    // } else {
    backgroundColor = Colors.white;
    // }

    var clickable = false;
    final MainAxisAlignment alignment;
    if (entity.isFromMe(andropContext.deviceId)) {
      alignment = MainAxisAlignment.end;
    } else {
      alignment = MainAxisAlignment.start;
    }

    final Widget content;
    if (entity.isFromMe(andropContext.deviceId)) {
      // 发送
      switch (sharedVideo.state) {
        case FileState.picked:
          clickable = true;
          content = _buildInlineVideoPlayer(true, sharedVideo, false);
          break;
        case FileState.waitToAccepted:
          clickable = false;
          content = _waitToAcceptedContent(sharedVideo);
          break;
        case FileState.inTransit:
          clickable = false;
          content = _inTransContent(sharedVideo);
          break;
        case FileState.sendCompleted:
        case FileState.receiveCompleted:
        case FileState.completed:
          clickable = true;
          content = _buildInlineVideoPlayer(true, sharedVideo, false);
          break;
        case FileState.cancelled:
        case FileState.sendFailed:
        case FileState.receiveFailed:
        case FileState.failed:
          clickable = true;
          content = _buildInlineVideoPlayer(true, sharedVideo, false);
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
              _confirmReceive(concertProvider);
            },
            child: AcceptMediaWidget(),
          );
          break;
        case FileState.inTransit:
        case FileState.sendCompleted:
          content = _inReceiveContent(sharedVideo);
        case FileState.receiveCompleted:
        case FileState.completed:
          clickable = true;
          content = _buildInlineVideoPlayer(false, sharedVideo, false);
        case FileState.cancelled:
        case FileState.sendFailed:
        case FileState.receiveFailed:
        case FileState.failed:
          content = const AspectRatio(
            aspectRatio: 1.333333,
            child: DecoratedBox(
              decoration: BoxDecoration(color: Colors.white),
              child: PreviewErrorWidget(),
            ),
          );
          break;
        default:
          throw StateError('Error receive state: ${sharedVideo.state}');
      }
    }
    return BubbleDecorationWidget(
      key: ValueKey(entity.shareable.id),
      entity: entity,
      child: FileBubbleInteraction(
        key: ValueKey(entity.shareable.id),
        bubble: entity,
        filePath: sharedVideo.content.path ?? '',
        clickable: clickable,
        child: _buildAspectContent(backgroundColor, sharedVideo, content),
      ),
    );
  }

  Widget _inReceiveContent(SharedFile sharedVideo) {
    return Stack(
      fit: StackFit.passthrough,
      children: [
        const DecoratedBox(
          decoration: const BoxDecoration(color: Color.fromRGBO(0, 0, 0, 0.5)),
          child: Center(
            child: SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(
                  backgroundColor: Colors.transparent,
                  color: Colors.white,
                  strokeWidth: 2.0,
                )),
          ),
        ),
        Align(
          alignment: Alignment.bottomLeft,
          child: TransInfoWidget(key: ValueKey(sharedVideo.id), entity: entity),
        )
      ],
    );
  }

  Stack _inTransContent(SharedFile sharedVideo) {
    return Stack(
      fit: StackFit.passthrough,
      children: [
        _buildInlineVideoPlayer(true, sharedVideo, true),
        Container(
          decoration: BoxDecoration(color: Colors.black.withOpacity(0.5)),
          width: double.infinity,
          height: double.infinity,
        ),
        Align(
          alignment: Alignment.center,
          child: const SizedBox(
              width: 18,
              height: 18,
              child: CircularProgressIndicator(
                backgroundColor: Colors.transparent,
                color: Colors.white,
                strokeWidth: 2.0,
              )),
        ),
        Align(
          alignment: Alignment.bottomLeft,
          child: TransInfoWidget(key: ValueKey(sharedVideo.id), entity: entity),
        )
      ],
    );
  }

  Stack _waitToAcceptedContent(SharedFile sharedVideo) {
    return Stack(
      fit: StackFit.passthrough,
      children: [
        _buildInlineVideoPlayer(true, sharedVideo, true),
        Container(
          decoration: const BoxDecoration(color: Color.fromRGBO(0, 0, 0, 0.5)),
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

  Container _buildAspectContent(
      Color backgroundColor, SharedFile sharedVideo, Widget content) {
    return Container(
      decoration: BoxDecoration(color: backgroundColor),
      child: LayoutBuilder(
          builder: (BuildContext context, BoxConstraints constraints) {
        const maxPhysicalSize = 250.0;

        if (sharedVideo.content.width == 0 || sharedVideo.content.height == 0) {
          return ConstrainedBox(
              constraints: BoxConstraints(
                  minWidth: 100,
                  maxWidth:
                      max(100, min(constraints.maxWidth - 60, maxPhysicalSize)),
                  minHeight: 100,
                  maxHeight: maxPhysicalSize),
              child: IntrinsicHeight(child: content));
        } else {
          return _aspectContent(
              maxPhysicalSize, constraints, context, sharedVideo, content);
        }
      }),
    );
  }

  SizedBox _aspectContent(double maxPhysicalSize, BoxConstraints constraints,
      BuildContext context, SharedFile sharedVideo, Widget content) {
    final width;
    final height;

    const minSize = 100;
    final maxSize =
        max(minSize, min(maxPhysicalSize, constraints.maxWidth - 60));

    final dpi = MediaQuery.of(context).devicePixelRatio;
    final imageOriginWidth = sharedVideo.content.width / dpi;
    final imageOriginHeight = sharedVideo.content.height / dpi;
    if (imageOriginWidth >= imageOriginHeight) {
      if (imageOriginWidth > maxSize) {
        width = maxSize;
      } else if (imageOriginWidth < minSize) {
        width = minSize;
      } else {
        width = imageOriginWidth;
      }
      height = width / imageOriginWidth * imageOriginHeight;
    } else {
      if (imageOriginHeight > maxSize) {
        height = maxSize;
      } else if (imageOriginHeight < minSize) {
        height = minSize;
      } else {
        height = imageOriginHeight;
      }
      width = height / imageOriginHeight * imageOriginWidth;
    }

    return SizedBox(
      width: width * 1.0,
      height: height * 1.0,
      child: content,
    );
  }

  void _confirmReceive(ConcertProvider concertProvider) async {
    if (await checkStoragePermission(context)) {
      concertProvider.confirmReceive(entity);
    }
  }

  Widget _buildInlineVideoPlayer(
      bool isFromSelf, SharedFile videoEntity, bool preview) {
    final previewWidget;
    if (videoEntity.content.resourceId.isEmpty || isDesktop()) {
      previewWidget = AspectRatioVideo(
          key: _videoWidget,
          videoPath: videoEntity.content.path!,
          preview: false);
    } else {
      previewWidget = Image(
          key: _videoWidget,
          image: FlixThumbnailProvider(
              id: videoEntity.id,
              resourceId: videoEntity.content.resourceId,
              preferWidth: 250,
              preferHeight: 250),
          fit: BoxFit.contain,
          errorBuilder: (
            BuildContext context,
            Object error,
            StackTrace? stackTrace,
          ) {
            talker.error('failed to preview video: ${videoEntity.id}', error,
                stackTrace);
            return _imageErrorWidget();
          });
    }

    return IntrinsicHeight(
      child: Stack(
        fit: StackFit.passthrough,
        children: [
          previewWidget,
          Align(
            alignment: Alignment.center,
            child: Visibility(
              visible: !preview,
              child: SvgPicture.asset('assets/images/ic_play.svg'),
            ),
          )
        ],
      ),
    );
  }

  Widget _imageErrorWidget() => const PreviewErrorWidget();
}
