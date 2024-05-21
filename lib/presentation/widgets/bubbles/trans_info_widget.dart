import 'package:flix/model/ui_bubble/shared_file.dart';
import 'package:flix/model/ui_bubble/ui_bubble.dart';
import 'package:flix/presentation/basic/progressbar/linear/animated_progress_bar.dart';
import 'package:flix/utils/file/size_utils.dart';
import 'package:flix/utils/file/speed_utils.dart';
import 'package:flix/utils/text/text_extension.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:gradient_txt/gradient_text.dart';

class TransInfoWidget extends StatefulWidget {
  final UIBubble entity;

  const TransInfoWidget({super.key, required this.entity});

  @override
  State<StatefulWidget> createState() => TransInfoWidgetState();
}

class TransInfoWidgetState extends State<TransInfoWidget> {
  UIBubble get entity => widget.entity;

  @override
  Widget build(BuildContext context) {
    assert(entity.shareable is SharedFile);
    final sharedFile = entity.shareable as SharedFile;
    bool showProgressBar = false;
    List<Color> progressBarColors = [
      const Color.fromRGBO(0, 122, 255, 1),
      const Color.fromRGBO(81, 181, 252, 1)
    ];
    List<Color> speedTextColors = [
      const Color.fromRGBO(18, 160, 255, 1),
      const Color.fromRGBO(7, 144, 255, 1),
    ];
    if (sharedFile.state == FileState.inTransit) {
      showProgressBar = true;
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 12, right: 12, bottom: 6),
          child: Row(
            children: [
              Flexible(
                child: Visibility(
                  visible: sharedFile.content.size > 0,
                  child: Padding(
                    padding: const EdgeInsets.only(right: 10.0),
                    child: Text(
                      sharedFile.content.size.formateBinarySize(),
                      style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w400,
                              color: Colors.white)
                          .fix(),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
              ),
              Flexible(
                child: Visibility(
                  visible: showProgressBar,
                  child:GradientText(
                    text: sharedFile.speed.formatSpeed(),
                    gradient: LinearGradient(
                        colors: speedTextColors),
                    style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w400).fix(),
                  ),
                ),
              ),
            ],
          ),
        ),
        AnimatedCrossFade(
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
        )
      ],
    );
  }
}
