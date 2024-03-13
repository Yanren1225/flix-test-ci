import 'dart:developer';
import 'dart:io';

import 'package:downloadsfolder/downloadsfolder.dart';
import 'package:flix/domain/log/flix_log.dart';
import 'package:flix/utils/file/file_helper.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:open_dir/open_dir.dart';
import 'package:open_filex/open_filex.dart';

class FileBubbleInteraction extends StatelessWidget {
  final String filePath;
  final Widget child;

  const FileBubbleInteraction(
      {super.key, required this.filePath, required this.child});

  @override
  Widget build(BuildContext context) {
    return InkWell(
        onDoubleTap: () {
          _openDir();
        },
        onTap: () {
          talker.verbose('filePath: $filePath');
          OpenFilex.open(filePath).then((value) {
            if (value.type != ResultType.done) {
              talker.error('Failed open file: $filePath, result: $value');
              _openDir();
            }
          });
        },
        child: child);
  }

  void _openDir() {
    if (Platform.isIOS || Platform.isAndroid) {
      openDownloadFolder().then((value) {
        if (value) {
          print('Download folder opened successfully');
        } else {
          print('Failed to open download folder');
        }
      }).catchError((error, stackTrace) =>
          print('Failed to open download folder: $error'));
    } else {
      getDefaultDestinationDirectory()
          .then((value) => OpenDir().openNativeDir(path: filePath))
          .catchError(
              (error) => print('Failed to open download folder: $error'));
    }
  }
}
