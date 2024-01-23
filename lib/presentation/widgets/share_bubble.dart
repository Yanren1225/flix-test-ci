import 'dart:io';
import 'dart:math';

import 'package:androp/model/bubble_entity.dart';
import 'package:androp/model/shareable.dart';
import 'package:androp/presentation/widgets/aspect_ratio_video.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:video_player/video_player.dart';

import '../../domain/androp_context.dart';

class ShareBubble extends StatelessWidget {
  final BubbleEntity entity;

  const ShareBubble({super.key, required this.entity});

  @override
  Widget build(BuildContext context) {
    if (entity.shareable is SharedText) {
      return ShareTextBubble(entity: entity);
    } else if (entity.shareable is SharedImage) {
      return ShareImageBubble(entity: entity);
    } else if (entity.shareable is SharedVideo) {
      return ShareVideoBubble(entity: entity);
    } else {
      return const Placeholder();
    }
  }
}

class ShareTextBubble extends StatelessWidget {
  final BubbleEntity entity;

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
  final BubbleEntity entity;
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
                  child: Image.file(File(sharedImage.content),
                      fit: BoxFit.contain)));
        }),
      ),
    );
  }
}

class ShareVideoBubble extends StatelessWidget {
  final BubbleEntity entity;
  const ShareVideoBubble({super.key, required this.entity});

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
                  child: _buildInlineVideoPlayer(sharedVideo.content)));
        }),
      ),
    );
  }

  Widget _buildInlineVideoPlayer(String videoUri) {
    final VideoPlayerController controller =
        VideoPlayerController.file(File(videoUri));
    // const double volume = kIsWeb ? 0.0 : 1.0;
    // controller.setVolume(volume);
    controller.initialize();
    controller.setLooping(true);
    controller.play();
    return Center(child: AspectRatioVideo(controller));
  }
}
