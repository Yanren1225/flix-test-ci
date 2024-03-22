import 'dart:io';
import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:open_dir/open_dir.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

Future<void> downloadFile(BuildContext context, String logs) async {
  if (Platform.isWindows) {
    final dir = await getTemporaryDirectory();
    final dirPath = dir.path;
    final fmtDate = DateTime.now().toString().replaceAll(":", " ");
    final file = await File('$dirPath/flix_release_logs_$fmtDate.txt')
        .create(recursive: true);
    await file.writeAsString(logs);
    await OpenDir().openNativeDir(path: file.path);
  } else {
    final dir = await getTemporaryDirectory();
    final dirPath = dir.path;
    final fmtDate = DateTime.now().toString().replaceAll(":", " ");
    final file = await File('$dirPath/flix_release_logs_$fmtDate.txt')
        .create(recursive: true);
    await file.writeAsString(logs);

    final box = context.findRenderObject() as RenderBox?;


    await Share.shareXFiles(<XFile>[
      XFile(file.path),
    ],
        sharePositionOrigin: box!.localToGlobal(Offset.zero) & box.size
    );
  }

}
