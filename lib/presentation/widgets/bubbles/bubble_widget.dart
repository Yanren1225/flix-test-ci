import 'package:flix/model/ship/primitive_bubble.dart';
import 'package:flix/model/ui_bubble/ui_bubble.dart';
import 'package:flix/presentation/widgets/bubbles/share_directory_bubble.dart';
import 'package:flix/presentation/widgets/bubbles/share_file_bubble.dart';
import 'package:flix/presentation/widgets/bubbles/share_image_bubble.dart';
import 'package:flix/presentation/widgets/bubbles/share_text_bubble.dart';
import 'package:flix/presentation/widgets/bubbles/share_time_bubble.dart';
import 'package:flix/presentation/widgets/bubbles/share_video_bubble.dart';
import 'package:flutter/material.dart';

class BubbleWidget extends StatelessWidget {
  final UIBubble uiBubble;

  BubbleWidget({super.key, required this.uiBubble});

  @override
  Widget build(BuildContext context) {
    switch (uiBubble.type) {
      case BubbleType.Text:
        return ShareTextBubble(key: ValueKey<String>(uiBubble.shareable.id), entity: uiBubble);
      case BubbleType.Image:
        return ShareImageBubble(key: ValueKey<String>(uiBubble.shareable.id), entity: uiBubble);
      case BubbleType.Video:
        return ShareVideoBubble(key: ValueKey<String>(uiBubble.shareable.id), entity: uiBubble);
      case BubbleType.File:
        return ShareFileBubble(key: ValueKey<String>(uiBubble.shareable.id), entity: uiBubble);
      case BubbleType.Directory:
        return ShareDirectoryBubble(
            key: ValueKey<String>(uiBubble.shareable.id), entity: uiBubble);
      case BubbleType.App:
        // return ShareAppBubble(entity: uiBubble);
        return ShareFileBubble(key: ValueKey<String>(uiBubble.shareable.id), entity: uiBubble);
      case BubbleType.Time:
        return ShareTimeBubble(key: ValueKey<String>(uiBubble.shareable.id), entity: uiBubble);
    }
  }
}





