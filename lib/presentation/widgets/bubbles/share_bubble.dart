import 'dart:io';
import 'dart:math';

import 'package:flix/domain/concert/concert_provider.dart';
import 'package:flix/domain/device/device_manager.dart';
import 'package:flix/model/ship/primitive_bubble.dart';
import 'package:flix/model/ui_bubble/shared_file.dart';
import 'package:flix/model/ui_bubble/ui_bubble.dart';
import 'package:flix/model/ui_bubble/shareable.dart';
import 'package:flix/presentation/widgets/app_icon.dart';
import 'package:flix/presentation/widgets/aspect_ratio_video.dart';
import 'package:flix/presentation/widgets/bubbles/share_file_bubble.dart';
import 'package:flix/presentation/widgets/bubbles/share_image_bubble.dart';
import 'package:flix/presentation/widgets/bubbles/share_text_bubble.dart';
import 'package:flix/presentation/widgets/bubbles/share_video_bubble.dart';
import 'package:flix/utils/file/size_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:provider/provider.dart';

// import 'package:thumbnailer/thumbnailer.dart';
import 'package:video_player/video_player.dart';

import '../../../domain/androp_context.dart';

class ShareBubble extends StatelessWidget {
  final UIBubble uiBubble;

  const ShareBubble({super.key, required this.uiBubble});

  @override
  Widget build(BuildContext context) {
    switch (uiBubble.type) {
      case BubbleType.Text:
        return ShareTextBubble(entity: uiBubble);
      case BubbleType.Image:
        return ShareImageBubble(entity: uiBubble);
      case BubbleType.Video:
        return ShareVideoBubble(entity: uiBubble);
      case BubbleType.File:
        return ShareFileBubble(entity: uiBubble);
      case BubbleType.App:
        // return ShareAppBubble(entity: uiBubble);
        return ShareFileBubble(entity: uiBubble);
    }
  }
}





