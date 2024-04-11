import 'dart:io';

import 'package:flix/domain/concert/concert_provider.dart';
import 'package:flix/domain/device/device_profile_repo.dart';
import 'package:flix/domain/log/flix_log.dart';
import 'package:flix/model/ui_bubble/shared_file.dart';
import 'package:flix/model/ui_bubble/ui_bubble.dart';
import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';

abstract class BaseFileBubble extends StatefulWidget {
  final UIBubble entity;

  const BaseFileBubble({Key? key, required this.entity}) : super(key: key);
}

abstract class BaseFileBubbleState<T extends BaseFileBubble> extends State<T> {
  UIBubble get entity => widget.entity;
  String? _tmpPath;


  @override
  void initState() {
    super.initState();
    final sharedFile = entity.shareable as SharedFile;
    if (entity.isFromMe(DeviceProfileRepo.instance.did)) {
      if (Platform.isMacOS) {
        sharedFile.content.startAccessPath();
      } else if (Platform.isIOS) {
        sharedFile.content.startAccessPath().then((path) {
          Future.delayed(Duration.zero, () {
            if (mounted) {
              if (path != null && path.isNotEmpty && path != _tmpPath && path != sharedFile.content.path) {
                talker.debug('old path: ${sharedFile.content.path}, new path: $path');
                _tmpPath = path;
                setState(() {
                  sharedFile.content.path = path;
                });
                ConcertProvider concertProvider = Provider.of(context, listen: false);
                concertProvider.updateFilePath(entity, path);
              }
            }
          });
        });
      }
    }
  }

  @override
  void dispose() {
    final sharedFile = entity.shareable as SharedFile;
    if (entity.isFromMe(DeviceProfileRepo.instance.did) && Platform.isMacOS) {
      sharedFile.content.stopAccessPath();
    }
    super.dispose();
  }

}