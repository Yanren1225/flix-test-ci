import 'dart:io';
import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

Future<void> downloadFile(BuildContext context, String logs) async {
  final dir = await getTemporaryDirectory();
  final dirPath = dir.path;
  final fmtDate = DateTime.now().toString().replaceAll(":", " ");
  final file = await File('$dirPath/flix_release_logs_$fmtDate.txt')
      .create(recursive: true);
  await file.writeAsString(logs);

  final size = MediaQuery.of(context).size;
  final box = context.findRenderObject() as RenderBox?;


  await Share.shareXFiles(<XFile>[
    XFile(file.path),
  ],
      sharePositionOrigin: box!.localToGlobal(Offset.zero) & box.size

  //     sharePositionOrigin: Rect.fromPoints(
  //   Offset.zero,
  //   Offset(size.width / 3 * 2, size.height),
  // )
  );
}
