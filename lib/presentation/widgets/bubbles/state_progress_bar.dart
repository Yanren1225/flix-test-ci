import 'package:flix/model/ui_bubble/shared_file.dart';
import 'package:flix/model/ui_bubble/ui_bubble.dart';
import 'package:flix/presentation/basic/progressbar/linear/animated_progress_bar.dart';
import 'package:flutter/cupertino.dart';

class StateProgressBar extends StatefulWidget {
  final UIBubble entity;

  const StateProgressBar({super.key, required this.entity});

  @override
  State<StatefulWidget> createState() => _StateProgressBarState();

}

class _StateProgressBarState extends State<StateProgressBar> {
  UIBubble get entity => widget.entity;

  @override
  Widget build(BuildContext context) {
    assert(entity.shareable is SharedFile);
    final sharedFile = entity.shareable as SharedFile;
    // AndropContext andropContext = Provider.of(context, listen: false);
    // final isFromMe = entity.isFromMe(andropContext.deviceId);
    bool showProgressBar = false;
    List<Color> progressBarColors = [
      const Color.fromRGBO(0, 122, 255, 1),
      const Color.fromRGBO(81, 181, 252, 1)
    ];
    if (sharedFile.state == FileState.inTransit) {
      showProgressBar = true;
    }

    return AnimatedCrossFade(
      key: ValueKey(sharedFile.id),
      crossFadeState: showProgressBar
          ? CrossFadeState.showFirst
          : CrossFadeState.showSecond,
      firstChild: AnimatedProgressBar(
          value: sharedFile.progress,
          duration: const Duration(milliseconds: 200),
          width: double.infinity,
          height: 6,
          backgroundColor: const Color.fromRGBO(247, 247, 247, 1),
          gradient: LinearGradient(colors: progressBarColors)),
      secondChild: const SizedBox(
        height: 6,
      ),
      duration: const Duration(milliseconds: 200),
    );
  }
}