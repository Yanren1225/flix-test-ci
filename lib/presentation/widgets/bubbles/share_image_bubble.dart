import 'dart:io';
import 'dart:math';

import 'package:flix/domain/androp_context.dart';
import 'package:flix/domain/concert/concert_provider.dart';
import 'package:flix/domain/log/flix_log.dart';
import 'package:flix/model/ui_bubble/shared_file.dart';
import 'package:flix/presentation/basic/corner/flix_decoration.dart';
import 'package:flix/presentation/basic/flix_thumbnail_provider.dart';
import 'package:flix/presentation/screens/base_screen.dart';
import 'package:flix/presentation/widgets/bubbles/accept_media_widget.dart';
import 'package:flix/presentation/widgets/bubbles/base_file_bubble.dart';
import 'package:flix/presentation/widgets/bubbles/bubble_decoration_widget.dart';
import 'package:flix/presentation/widgets/bubbles/trans_info_widget.dart';
import 'package:flix/presentation/widgets/bubbles/wait_to_accept_media_widget.dart';
import 'package:flix/presentation/widgets/segements/file_bubble_interaction.dart';
import 'package:flix/presentation/widgets/segements/preview_error_widget.dart';
import 'package:flix/theme/theme_extensions.dart';
import 'package:flix/utils/platform_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
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
    Color backgroundColor = Theme.of(context).flixColors.background.primary;
    bool clickable = false;
    final Widget Function(int? cacheWidth, int? cacheHeight) content;
    if (entity.isFromMe(andropContext.deviceId)) {
      // 发送
      switch (sharedImage.state) {
        case FileState.picked:
          clickable = true;
          content = (cacheWidth, cacheHeight) =>
              _normalContent(sharedImage, cacheWidth, cacheHeight);
          break;
        case FileState.waitToAccepted:
          clickable = false;
          content = (w, h) => _waitToAcceptedContent(sharedImage, w, h);
          break;
        case FileState.inTransit:
          clickable = false;

          content = (w, h) => _inTransContent(sharedImage, w, h);
          break;
        case FileState.sendCompleted:
        case FileState.receiveCompleted:
        case FileState.completed:
          clickable = true;
          content = (cacheWidth, cacheHeight) =>
              _normalContent(sharedImage, cacheWidth, cacheHeight);
          break;
        case FileState.cancelled:
        case FileState.sendFailed:
        case FileState.receiveFailed:
        case FileState.failed:
          clickable = true;
          content = (cacheWidth, cacheHeight) =>
              _normalContent(sharedImage, cacheWidth, cacheHeight);
          break;
        default:
          throw StateError('Error send state: ${sharedImage.state}');
      }
    } else {
      // 接收
      switch (sharedImage.state) {
        case FileState.waitToAccepted:
          content = (w, h) => InkWell(
                onTap: () {
                  _confirmReceive(concertProvider);
                },
                child: const AcceptMediaWidget(),
              );
        case FileState.inTransit:
        case FileState.sendCompleted:
          content = (w, h) => _inReceiveContent(sharedImage);
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
          content = (w, h) => _receiveErrorContent();
          break;
        default:
          throw StateError('Error receive state: ${sharedImage.state}');
      }
    }

    return BubbleDecorationWidget(
      key: ValueKey(entity.shareable.id),
      entity: entity,
      child: BubbleInteraction(
        key: ValueKey(entity.shareable.id),
        bubble: entity,
        path: sharedImage.content.path ?? '',
        clickable: clickable,
        child: _buildAspectContent(backgroundColor, sharedImage, content),
      ),
    );
  }

  AspectRatio _receiveErrorContent() {
    return AspectRatio(
      aspectRatio: 1.333333,
      child: DecoratedBox(
        decoration: FlixDecoration(color: Colors.white),
        child: _imageErrorWidget(),
      ),
    );
  }

  Widget _inReceiveContent(SharedFile sharedImage) {
    return Stack(
      fit: StackFit.passthrough,
      children: [
        DecoratedBox(
          decoration: FlixDecoration(color: const Color.fromRGBO(0, 0, 0, 0.5)),
          child: const Center(
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
          child: TransInfoWidget(key: ValueKey(sharedImage.id), entity: entity),
        ),
      ],
    );
  }

  Widget _normalContent(
      SharedFile sharedImage, int? cacheWidth, int? cacheHeight) {
    return _image(true, sharedImage,
        cacheWidth: cacheWidth, cacheHeight: cacheHeight);
  }

  Stack _waitToAcceptedContent(SharedFile sharedImage, int? w, int? h) {
    return Stack(
      fit: StackFit.passthrough,
      children: [
        Container(
          decoration: FlixDecoration(color: const Color.fromRGBO(0, 0, 0, 0.5)),
          width: double.infinity,
          height: double.infinity,
          child: _normalContent(sharedImage, w, h),
        ),
        const Align(
          alignment: Alignment.center,
          child: WaitToAcceptMediaWidget(),
        )
      ],
    );
  }

  Stack _inTransContent(SharedFile sharedImage, int? w, int? h) {
    return Stack(
      fit: StackFit.passthrough,
      children: [
        Container(
          decoration: FlixDecoration(color: const Color.fromRGBO(0, 0, 0, 0.5)),
          width: double.infinity,
          height: double.infinity,
          child: _normalContent(sharedImage, w, h),
        ),
        const Align(
          alignment: Alignment.center,
          child: SizedBox(
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
          child: TransInfoWidget(key: ValueKey(sharedImage.id), entity: entity),
        )
      ],
    );
  }

  DecoratedBox _buildAspectContent(
      Color backgroundColor,
      SharedFile sharedImage,
      Widget Function(int? cacheWidth, int? cacheHeight) content) {
    return DecoratedBox(
      decoration: FlixDecoration(color: backgroundColor),
      child: LayoutBuilder(
          builder: (BuildContext context, BoxConstraints constraints) {
        const maxPhysicalSize = 250.0;
        // Platform.isAndroid || Platform.isIOS ? 250.0 : 300.0;

        if (sharedImage.content.width == 0 || sharedImage.content.height == 0) {
          return ConstrainedBox(
              constraints: BoxConstraints(
                  minWidth: 100,
                  maxWidth:
                      max(100, min(constraints.maxWidth - 60, maxPhysicalSize)),
                  minHeight: 100,
                  maxHeight: maxPhysicalSize),
              child: IntrinsicWidth(
                  child: IntrinsicHeight(child: content(null, null))));
        } else {
          return _aspectContent(
              maxPhysicalSize, constraints, context, sharedImage, content);
        }
      }),
    );
  }

  SizedBox _aspectContent(
      double maxPhysicalSize,
      BoxConstraints constraints,
      BuildContext context,
      SharedFile sharedImage,
      Widget Function(int? cacheWidth, int? cacheHeight) content) {
    double width;
    double height;

    const minSize = 100;
    final maxSize =
        max(minSize, min(maxPhysicalSize, constraints.maxWidth - 60));

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
        child: content((width * dpi).toInt(), (height * dpi).toInt()));
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

    talker.debug("_image path = ${sharedFile.content.nameWithSuffix} content_path = ${sharedFile.content.path}");
    if (sharedFile.content.nameWithSuffix.isNotEmpty &&
        sharedFile.content.nameWithSuffix.endsWith(".svg")) {
      return SvgPicture.file(File(sharedFile.content.path.toString()));
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

  Widget _imageErrorWidget() => const PreviewErrorWidget();
}
