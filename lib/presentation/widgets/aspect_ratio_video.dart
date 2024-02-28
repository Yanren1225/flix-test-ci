import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:video_player/video_player.dart';

class AspectRatioVideo extends StatefulWidget {
  const AspectRatioVideo({ super.key, required this.videoPath, required this.preview});

  // final VideoPlayerController? controller;
  final String videoPath;
  final bool preview;

  @override
  AspectRatioVideoState createState() => AspectRatioVideoState();
}

class AspectRatioVideoState extends State<AspectRatioVideo> {
  late VideoPlayerController controller;

  bool get preview => widget.preview;

  bool initialized = false;

  AspectRatioVideoState();

  void _onVideoControllerUpdate() {
    if (!mounted) {
      return;
    }
    if (initialized != controller!.value.isInitialized) {
      initialized = controller!.value.isInitialized;
      setState(() {});
    }
  }

  @override
  void initState() {
    super.initState();
    controller = VideoPlayerController.file(File(widget.videoPath));
    controller!.addListener(_onVideoControllerUpdate);
    controller?.initialize();
    controller?.setLooping(false);
  }

  @override
  void dispose() {
    controller!.removeListener(_onVideoControllerUpdate);
    controller?.dispose();
    super.dispose();
  }

  @override
  void activate() {
    super.activate();
    // controller?.play();
  }

  @override
  void deactivate() {
    controller?.pause();
    super.deactivate();
  }

  @override
  Widget build(BuildContext context) {
    if (initialized) {
      return IntrinsicHeight(
        child: Stack(
          fit: StackFit.passthrough,
          children: [
            Center(
              child: AspectRatio(
                aspectRatio: controller!.value.aspectRatio,
                child: VideoPlayer(controller!),
              ),
            ),
            Align(
              alignment: Alignment.center,
              child: Visibility(
                visible: !preview,
                child: IconButton(
                    onPressed: () {
                      controller?.play();
                    },
                    icon: SvgPicture.asset('assets/images/ic_play.svg')),
              ),
            )
          ],
        ),
      );
    } else {
      return Container();
    }
  }
}
