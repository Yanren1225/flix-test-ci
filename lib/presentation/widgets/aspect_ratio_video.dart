import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:video_player/video_player.dart';

class AspectRatioVideo extends StatefulWidget {
  const AspectRatioVideo(this.controller, this.preview, {super.key});

  final VideoPlayerController? controller;
  final bool preview;

  @override
  AspectRatioVideoState createState() => AspectRatioVideoState();
}

class AspectRatioVideoState extends State<AspectRatioVideo> {
  VideoPlayerController? get controller => widget.controller;

  bool get preview => widget.preview;

  bool initialized = false;

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
    controller!.addListener(_onVideoControllerUpdate);
  }

  @override
  void dispose() {
    controller!.removeListener(_onVideoControllerUpdate);
    super.dispose();
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
