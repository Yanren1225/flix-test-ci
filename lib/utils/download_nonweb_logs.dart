import 'dart:io';

import 'package:archive/archive_io.dart';
import 'package:flix/domain/log/persistence/log_persistence_proxy.dart';
import 'package:flix/domain/log/persistence/partition_log_file.dart';
import 'package:flix/utils/android/android_utils.dart';
import 'package:flix/utils/file/file_helper.dart';
import 'package:flutter/cupertino.dart';
import 'package:intl/intl.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart' as SharePlus;
import 'package:share/share.dart' as Share;

Future<void> downloadFile(BuildContext context, String logs) async {
  final File file;
  if (Platform.isWindows) {
    final dir = await getTemporaryDirectory();
    final dirPath = dir.path;
    final fmtDate = DateTime.now().toString().replaceAll(":", " ");
    file = await File('$dirPath/flix_release_logs_$fmtDate.txt')
        .create(recursive: true);
    await file.writeAsString(logs);
  } else {
    final dir = await getTemporaryDirectory();
    final dirPath = dir.path;
    final fmtDate = DateTime.now().toString().replaceAll(":", " ");
    file = await File('$dirPath/flix_release_logs_$fmtDate.txt')
        .create(recursive: true);
    await file.writeAsString(logs);
  }

  shareFile(context, file);
}

Future<void> packageLogAndShare(BuildContext context) async {
  await logPersistence.waitFlush();
  final logDir = await getApplicationSupportDirectory();
  Directory? outParentDir = await getApplicationDocumentsDirectory();
  if(Platform.isAndroid){
    outParentDir = await getDownloadsDirectory();
  }
  final now = DateTime.now();
  final formatter = DateFormat("yyyy_MM_dd_HH_mm_ss");
  final nowString = formatter.format(now);

  final file = await zipDirectory(
      "${logDir.path}/log", "${outParentDir?.path}/log/$nowString.zip");
  await shareFile(context, file);
}

Future<File> zipDirectory(String logDir, String zipFilePath) async {
  final logFiles = getAllLogFileEntities(logDir);

  // 创建一个Archive对象
  Archive archive = Archive();
  for (File file in logFiles) {
    // 读取文件内容
    List<int> bytes = file.readAsBytesSync();
    // 对于每个文件，将其添加到archive中
    // 使用文件相对于目录的路径作为在ZIP中的路径
    String fileName = path.relative(file.path, from: logDir);
    archive.addFile(ArchiveFile(fileName, bytes.length, bytes));
  }

  // 编码archive对象为ZIP格式的字节流
  List<int>? zipBytes = ZipEncoder().encode(archive);

  if (zipBytes != null) {
    // 将ZIP字节流写入文件
    final zipFile = File(zipFilePath);
    await zipFile.create(recursive: true);
    await zipFile.writeAsBytes(zipBytes);
    return zipFile;
  } else {
    throw Exception('Failed to compress directory into ZIP file');
  }
}

Future<void> shareFile(BuildContext context, File file) async {
  if (Platform.isWindows) {
    await openFileDirectoryOnWindows(file.path);
  }else if(Platform.isAndroid){
    List<String> files = List.empty(growable: true);
    files.add(file.path);
    await AndroidUtils.shareFile(file.path);
  } else {
    final box = context.findRenderObject() as RenderBox?;
    await SharePlus.Share.shareXFiles(<SharePlus.XFile>[
      SharePlus.XFile(file.path),
    ], sharePositionOrigin: box!.localToGlobal(Offset.zero) & box.size);
  }
}
